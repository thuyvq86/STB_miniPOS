/* ========================================================================= */
/**
 * Routines for working with DER TLV objects
 * (see ITU-T Recommendation X.690, ISO/IEC 8825-1)
 *
 * Copyright (C) 2012 Ingenico GmbH
 */
/* =========== INCLUDES ==================================================== */

#include <stddef.h>
#include <assert.h>

#include "derTlv.h"

/* =========== PRIVATE PROTOTYPES ========================================== */

/** Encodes TLV object header
 *
 * @retval OK - success
 * @retval ERR_TLV_TAG_INVALID - tag is invalid
 * @retval ERR_TLV_OBJECT_BUFFER_OVERFLOW - no more space in work buffer
 */
errorId_t
tlvContextObjectHeaderAdd(
   /** TLV object composition context */
   tlvContext_t *const context,
   /** Tag to add */
   const unsigned long tag,
   /** Length of value */
   const size_t valueLength
);

/* =========== PUBLIC FUNCTIONS ============================================ */

errorId_t
tlvTagLengthCalculate(
   const unsigned long tag_,
   size_t *const length
) {
   errorId_t r = OK;
   unsigned long tag = tag_;
   assert(length != NULL);
   *length = 1;

   if (tag > 0xFF) {
      /* multi-octet tag */
      if ((tag & 0x80) == 0) {
         (*length)++;
         tag >>= 8;
         while (tag > 0xFF) {
            if ((tag & 0x80) == 0) {
               /* an inner octet of multi-octet tag is invalid */
               r = ERR_TLV_TAG_INVALID;
               break;
            }
            (*length)++;
            tag >>= 8;
         }
         if (r == OK) {
            if ((tag & 0x1F) < 0x1F) {
               /* the first octet of multi-octet tag is invalid */
               r = ERR_TLV_TAG_INVALID;
            }
         }
      } else {
         /* the last octet of multi-octet tag is invalid */
         r = ERR_TLV_TAG_INVALID;
      }
   } else {
      if ((tag & 0x1F) == 0x1F) {
         /* single-octet tag is invalid */
         r = ERR_TLV_TAG_INVALID;
      }
   }
   return r;
}

void
tlvContextInitialize(
   tlvContext_t *const context,
   void *const buffer,
   const size_t bufferSize,
   size_t *const objects,
   const unsigned int objectCountLimit
) {
   assert(context != NULL);
   assert(objects != NULL);
   assert(objectCountLimit > 0);
   clear(*context);
   context->buffer = buffer;
   objects[0] = context->offset = context->bufferSize = bufferSize;
   context->objects = objects;
   context->objectCountLimit = objectCountLimit;
}

errorId_t
tlvContextObjectAdd(
   tlvContext_t *const context,
   const unsigned long tag,
   const void *const value,
   const size_t valueLength
) {
   errorId_t r = OK;
   assert(context != NULL);
   assert(context->buffer != NULL);
   assert(context->objects != NULL);

   if (context->objectCount + 1 < context->objectCountLimit) {
      if (valueLength < context->offset) {
         void *const target = context->buffer + context->offset - valueLength;
         context->offset -= valueLength;
         r = tlvContextObjectHeaderAdd(context, tag, valueLength);
         if (r == OK) {
            context->objectCount++;
            context->objects[context->objectCount] = context->offset;
            memcpy(target, value, valueLength);
         } else {
            /* something went wrong, stepping back */
            context->offset += valueLength;
         }
      } else {
         /* there would be no place for object in buffer */
         r = ERR_TLV_OBJECT_BUFFER_OVERFLOW;
      }
   } else {
      /* there would be no place for accounting of the new object */
      r = ERR_TLV_OBJECT_TABLE_OVERFLOW;
   }
   return r;
}

errorId_t
tlvContextConstructedObjectAdd(
   tlvContext_t *const context,
   const unsigned long tag,
   const unsigned int objectCount
) {
   errorId_t r = OK;
   assert(context != NULL);
   assert(context->objects != NULL);

   if (objectCount > context->objectCount) {
      /* there are not that many top level objects available */
      r = ERR_TLV_NOT_ENOUGH_OBJECTS;
   } else {
      if (context->objectCount + 1 - objectCount < context->objectCountLimit) {
         size_t length = context->objects[context->objectCount - objectCount]
            - context->objects[context->objectCount];
         r = tlvContextObjectHeaderAdd(context, tag, length);
         if (r == OK) {
            context->objectCount -= objectCount;
            context->objectCount++;
            context->objects[context->objectCount] = context->offset;
         }
      } else {
         /* there would be no place for accounting of the new object */
         r = ERR_TLV_OBJECT_TABLE_OVERFLOW;
      }
   }
   return r;
}

void *
tlvContextObjectGet(
   const tlvContext_t *const context
) {
   assert(context != NULL);
   assert(context->buffer != NULL);
   return context->buffer + context->offset;
}

size_t
tlvContextObjectSizeGet(
   const tlvContext_t *const context
) {
   assert(context != NULL);
   assert(context->objects != NULL);
   if (context->objectCount > 0) {
      return context->objects[context->objectCount - 1] - context->offset;
   }
   return 0;
}

errorId_t
tlvObjectDecode(
   const unsigned char *const buffer,
   const size_t bufferSize,
   unsigned long *const tag,
   size_t *const valueLength,
   const unsigned char **const value
) {
   errorId_t r = OK;
   size_t i = 1;
   size_t tagLength;
   assert(buffer != NULL);
   assert(tag != NULL);
   assert(valueLength != NULL);
   assert(value != NULL);

   if (bufferSize > 0) {
      *tag = *buffer;
      if ((*buffer & 0x1F) == 0x1F) {
         /* more than one byte for tag */
         while (i < bufferSize) {
            *tag = (*tag << 8) | buffer[i];
            if ((buffer[i] & 0x80) == 0) {
               /* the last byte of tag */
               break;
            }
            i++;
         }
         i++;
      }
   }
   tagLength = i;
   if (i < bufferSize) {
      if (buffer[i] > 0x7F) {
         /* long length field format */
         size_t lengthLength = buffer[i] & 0x7F;
         if (i + lengthLength < bufferSize) {
            *valueLength = 0;
            i++;
            while (lengthLength > 0 && buffer[i] == 0) {
               /* skipping over 0 in leading bytes */
               i++;
               lengthLength--;
            }
            if (lengthLength > sizeof(*valueLength)) {
               /* length of value is too large */
               r = ERR_TLV_LENGTH_OVERFLOW;
            } else {
               while (lengthLength > 0) {
                  /* acquiring significant bytes */
                  *valueLength = (*valueLength << 8) | buffer[i];
                  i++;
                  lengthLength--;
               }
            }
         } else {
            /* insufficient amount of data provided for value length */
            r = ERR_TLV_LENGTH_DATA_SHORTAGE;
         }
      } else {
         *valueLength = buffer[i];
         i++;
      }
   } else {
      if (i > bufferSize) {
         /* insufficient amount of data provided for tag */
         r = ERR_TLV_TAG_DATA_SHORTAGE;
      } else {
         /* insufficient amount of data provided for value length */
         r = ERR_TLV_LENGTH_DATA_SHORTAGE;
      }
   }
   if (r == OK) {
      /* length of value is ok */
      *value = buffer + i;
      if (tagLength > sizeof(*tag)) {
         /* tag is too long */
         r = ERR_TLV_TAG_OVERFLOW;
      }
   }
   return r;
}

/* =========== PRIVATE FUNCTIONS =========================================== */

errorId_t
tlvContextObjectHeaderAdd(
   tlvContext_t *const context,
   const unsigned long tag_,
   const size_t valueLength_
) {
   errorId_t r;
   size_t size;
   assert(context != NULL);
   assert(context->buffer != NULL);

   r = tlvTagLengthCalculate(tag_, &size);
   if (r == OK) {
      size_t valueLength = valueLength_;
      if (valueLength > 0x7F) {
         /* long form length encoding */
         do {
            size++;
            valueLength >>= 8;
         } while (valueLength > 0);
      }
      if (size < context->offset) {
         /* there is sufficient space */
         unsigned char *target = context->buffer + context->offset;
         unsigned long tag = tag_;
         valueLength = valueLength_;
         size = 0;
         do {
            target--;
            *target = (unsigned char)(valueLength & 0xFF);
            size++;
            valueLength >>= 8;
         } while (valueLength > 0);
         if (valueLength_ > 0x7F) {
            /* long form length encoding */
            target--;
            *target = (unsigned char)(0x80 | size);
            size++;
         }
         do {
            target--;
            *target = (unsigned char)(tag & 0xFF);
            size++;
            tag >>= 8;
         } while (tag > 0);
         context->offset -= size;
      } else {
         /* there would be no place for header in buffer */
         r = ERR_TLV_OBJECT_BUFFER_OVERFLOW;
      }
   }
   return r;
}

/* ========================== END OF FILE ================================== */
