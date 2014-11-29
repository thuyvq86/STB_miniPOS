package com.stb.minipos.ui.view;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;

import com.github.gcacace.signaturepad.views.SignaturePad;

public class SignatureView extends SignaturePad {

	public SignatureView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		int width = getMeasuredWidth();
		int height = getMeasuredHeight();
		int widthWithoutPadding = width - getPaddingLeft() - getPaddingRight();
		int heightWithoutPadding = height - getPaddingTop()
				- getPaddingBottom();

		heightWithoutPadding = (int) (widthWithoutPadding * 3 / 5);
		height = heightWithoutPadding + getPaddingTop() + getPaddingBottom();

		if (MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.EXACTLY) {
			width = getMeasuredWidth();
		}
		if (MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.EXACTLY) {
			height = getMeasuredHeight();
		}

		setMeasuredDimension(width, height);
	}

	public void setSignatureListener(SignatureListener listener) {
		this.listener = listener;
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		if (listener != null) {
			listener.onDraw();
		}
	}

	@Override
	public void clear() {
		super.clear();
		if (listener != null) {
			listener.onClear();
		}
	}

	private SignatureListener listener;

	public interface SignatureListener {
		public void onDraw();

		public void onClear();
	}
}
