/* ========================================================================= */
/**
 * Routines for working with DER TLV objects - declarations
 * (see ITU-T Recommendation X.690, ISO/IEC 8825-1)
 *
 * Copyright (C) 2012 Ingenico GmbH
 */
/* =========== INCLUDES ==================================================== */

#include <string.h>

/* =========== DEFINES ===================================================== */

/** Success */
#define OK 0

/** Insufficient amount of data provided for TLV object tag. */
#define ERR_TLV_TAG_DATA_SHORTAGE 0x200A0110

/** TLV object tag is too long. */
#define ERR_TLV_TAG_OVERFLOW 0x200A0111

/** Insufficient amount of data provided for TLV object value length. */
#define ERR_TLV_LENGTH_DATA_SHORTAGE 0x200A0112

/** TLV object value is too long. */
#define ERR_TLV_LENGTH_OVERFLOW 0x200A0113

/** There would be no place for object in buffer inside context */
#define ERR_TLV_OBJECT_BUFFER_OVERFLOW 0x200A0148

/** There would be no place for accounting of the new object inside context */
#define ERR_TLV_OBJECT_TABLE_OVERFLOW 0x200A0149

/** There are not that many top level objects available inside context */
#define ERR_TLV_NOT_ENOUGH_OBJECTS 0x200A014A

/** The provided tag is not a valid TLV DER tag */
#define ERR_TLV_TAG_INVALID 0x200A014B

#define clear(v) memset(&(v), 0, sizeof(v))

/** checks if TLV tag is constructed */
#define tlvTagIsConstructed(t) \
   ((t) & (0x20 \
      << (((t) > 0xFF) ? (((t) > 0xFFFF) ? (((t) > 0xFFFFFF) \
         ? 24 : 16) : 8) : 0)))

/* =========== DATA TYPES ================================================== */

/** Error identifier */
typedef int errorId_t;

/** TLV object composition context */
typedef struct {
   /** Construction buffer */
   unsigned char *buffer;

   /** Size of construction buffer */
   size_t bufferSize;

   /** Work offset within construction buffer */
   size_t offset;

   /** Offsets of top level objects within buffer */
   size_t *objects;

   /** Maximal number of top level objects */
   unsigned int objectCountLimit;

   /** Number of top level objects */
   unsigned int objectCount;
} tlvContext_t;

/* =========== PUBLIC PROTOTYPES =========================================== */

/** Verifies TLV tag and calculates its length
 *
 * @retval OK - success
 * @retval ERR_TLV_TAG_INVALID - tag is invalid
 */
errorId_t
tlvTagLengthCalculate(
   /** Tag to verify and calculate length for */
   const unsigned long tag,
   /** Length of TLV tag calculated */
   size_t *const length
);

/** Initializes TLV object composition context */
void
tlvContextInitialize(
   /** TLV object composition context to initialize */
   tlvContext_t *const context,
   /** Work buffer for holding composed objects */
   void *const buffer,
   /** Size of the work buffer */
   const size_t bufferSize,
   /** Work table for keeping track of top level objects;
    * Top level objects are those which are not nested
    * inside any constructed object yet.
    */
   size_t *const objects,
   /** Number of entries in work table;
    * Make sure it is large enough to accommodate any
    * number of top level object that may appear
    * during construction plus 1 extra entry;
    */
   const unsigned int objectCountLimit
);

/** Encodes a complete TLV object.
 *
 * @retval OK - success
 * @retval ERR_TLV_TAG_INVALID - tag is invalid
 * @retval ERR_TLV_OBJECT_BUFFER_OVERFLOW - no more space in work buffer
 * @retval ERR_TLV_OBJECT_TABLE_OVERFLOW - no more space in object table
 */
errorId_t
tlvContextObjectAdd(
   /** TLV object composition context */
   tlvContext_t *const context,
   /** Tag of the object to encode */
   const unsigned long tag,
   /** Value of the object to encode */
   const void *const value,
   /** Length of the object to encode */
   const size_t valueLength
);

/** Encodes a complete constructed TLV object.
 * Constructed TLV object is composed using top level TLV objects
 * currently present within context.
 *
 * @retval OK - success
 * @retval ERR_TLV_NOT_ENOUGH_OBJECTS - too few top level objects present
 * @retval ERR_TLV_TAG_INVALID - tag is invalid
 * @retval ERR_TLV_OBJECT_BUFFER_OVERFLOW - no more space in work buffer
 * @retval ERR_TLV_OBJECT_TABLE_OVERFLOW - no more space in object table
 */
errorId_t
tlvContextConstructedObjectAdd(
   /** TLV object composition context */
   tlvContext_t *const context,
   /** Tag of the object to encode */
   const unsigned long tag,
   /** Number of existing top level objects in context to consume */
   const unsigned int objectCount
);

/** Retrieves pointer to the last TLV object constructed */
void *
tlvContextObjectGet(
   /** TLV object composition context */
   const tlvContext_t *const context
);

/** Retrieves size of the last TLV object constructed */
size_t
tlvContextObjectSizeGet(
   /** TLV object composition context */
   const tlvContext_t *const context
);

/** Decodes DER TLV object.
 *
 * @pre buffer != NULL
 * @pre tag != NULL
 * @pre valueLength != NULL
 * @pre value != NULL
 *
 * @retval OK - success
 * @retval ERR_TLV_LENGTH_OVERFLOW - length of value is too large
 * @retval ERR_TLV_LENGTH_DATA_SHORTAGE - need more data for value length
 * @retval ERR_TLV_TAG_OVERFLOW - tag is too long
 * @retval ERR_TLV_TAG_DATA_SHORTAGE - need more data for tag field
 */
errorId_t
tlvObjectDecode(
   /** Buffer containing TLV object to decode */
   const unsigned char *const buffer,
   /** Size of data in buffer to decode */
   const size_t bufferSize,
   /** tag of TLV object decoded */
   unsigned long *const tag,
   /** length of TLV object data */
   size_t *const valueLength,
   /** poiner to TLV object data (within buffer) */
   const unsigned char **const value
);

/* ========================== END OF FILE ================================== */
