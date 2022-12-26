package com.cloudroom.whiteboardkt

import android.graphics.Color
import android.view.View
import android.widget.ImageView
import android.widget.PopupWindow
import com.cloudroom.cloudroomvideosdk.model.BoardViewToolAttr
import com.examples.tool.DrawableUtils
import com.examples.tool.Tools

/**
 * Created by zjw on 2022/8/10.
 */
open class PenStylePop(contentView: View) : PopupWindow(
    contentView,
    Tools.dp2px(contentView.context, 300),
    Tools.dp2px(contentView.context, 215)
) {

    private var mSelectPixelId = R.id.ivSize1
    private var mSelectColorId = R.id.ivRed
    private var mSize1: ImageView? = null
    private var mSize2: ImageView? = null
    private var mSize3: ImageView? = null
    private var mSize4: ImageView? = null

    private var mIvGray: ImageView? = null
    private var mIvBlack: ImageView? = null
    private var mIvRed: ImageView? = null
    private var mIvOrange: ImageView? = null
    private var mIvYellow: ImageView? = null
    private var mIvGreen: ImageView? = null
    private var mIvBlue: ImageView? = null
    private var mIvDeepBlue: ImageView? = null
    private var mIvDeepPurple: ImageView? = null
    private var mIvPurple: ImageView? = null

    private var mSelectListener: () -> Unit = {}
    private var mBoardViewToolAttr =
        BoardViewToolAttr()

    init {
        isFocusable = true
        isTouchable = true
        mSize1 = contentView.findViewById(R.id.ivSize1)
        mSize2 = contentView.findViewById(R.id.ivSize2)
        mSize3 = contentView.findViewById(R.id.ivSize3)
        mSize4 = contentView.findViewById(R.id.ivSize4)

        mSize1?.setOnClickListener {
            mBoardViewToolAttr.setLineWidth(1)
            refreshBg(it.id)
        }
        mSize2?.setOnClickListener {
            mBoardViewToolAttr.setLineWidth(2)
            refreshBg(it.id)
        }
        mSize3?.setOnClickListener {
            mBoardViewToolAttr.setLineWidth(4)
            refreshBg(it.id)
        }
        mSize4?.setOnClickListener {
            mBoardViewToolAttr.setLineWidth(8)
            refreshBg(it.id)
        }

        mIvGray = contentView.findViewById(R.id.ivGray)
        mIvBlack = contentView.findViewById(R.id.ivBlack)
        mIvRed = contentView.findViewById(R.id.ivRed)
        mIvOrange = contentView.findViewById(R.id.ivOrange)
        mIvYellow = contentView.findViewById(R.id.ivYellow)
        mIvGreen = contentView.findViewById(R.id.ivGreen)
        mIvBlue = contentView.findViewById(R.id.ivBlue)
        mIvDeepBlue = contentView.findViewById(R.id.ivDeepBlue)
        mIvDeepPurple = contentView.findViewById(R.id.ivDeepPurple)
        mIvPurple = contentView.findViewById(R.id.ivPurple)

        mIvGray?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#F0F0F0"))
            refreshBg(it.id, false)
        }
        mIvBlack?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#7B7B7B"))
            refreshBg(it.id, false)
        }
        mIvRed?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#FF0000"))
            refreshBg(it.id, false)
        }
        mIvOrange?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#FF6B00"))
            refreshBg(it.id, false)
        }
        mIvYellow?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#FFB800"))
            refreshBg(it.id, false)
        }
        mIvGreen?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#68DB00"))
            refreshBg(it.id, false)
        }
        mIvBlue?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#00DDFF"))
            refreshBg(it.id, false)
        }
        mIvDeepBlue?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#007FFF"))
            refreshBg(it.id, false)
        }
        mIvDeepPurple?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#BD00FF"))
            refreshBg(it.id, false)
        }
        mIvPurple?.setOnClickListener {
            mBoardViewToolAttr.setColor( Color.parseColor("#FF00F4"))
            refreshBg(it.id, false)
        }
        contentView.background = DrawableUtils.getShadowDrawable(
            contentView.context, Color.WHITE, 10, 6, 6
        )

    }

    fun setSelectListener(listener: () -> Unit): PenStylePop {
        mSelectListener = listener
        return this
    }

    private fun refreshBg(id: Int, isSize: Boolean = true, dismiss: Boolean = true) {
        var lastId = 0
        if (isSize) {
            lastId = mSelectPixelId
            mSelectPixelId = id
        } else {
            lastId = mSelectColorId
            mSelectColorId = id
        }
        contentView.findViewById<ImageView>(lastId).background = null
        contentView.findViewById<ImageView>(id).setBackgroundColor(Color.parseColor("#e9e9e9"))
        mSelectListener()
        if (dismiss) {
            dismiss()
        }
    }

    fun setCurSelect(attr: BoardViewToolAttr): PopupWindow {
        mBoardViewToolAttr=attr
        mSelectPixelId = when (mBoardViewToolAttr.lineWidth) {
            2 -> R.id.ivSize2
            4 -> R.id.ivSize3
            8 -> R.id.ivSize4
            else -> R.id.ivSize1
        }
        refreshBg(mSelectPixelId, dismiss = false)
        mSelectColorId = when (mBoardViewToolAttr.color) {
            Color.parseColor("#F0F0F0") -> R.id.ivGray
            Color.parseColor("#7B7B7B") -> R.id.ivBlack
            Color.parseColor("#FF6B00") -> R.id.ivOrange
            Color.parseColor("#FFB800") -> R.id.ivYellow
            Color.parseColor("#68DB00") -> R.id.ivGreen
            Color.parseColor("#00DDFF") -> R.id.ivBlue
            Color.parseColor("#007FFF") -> R.id.ivDeepBlue
            Color.parseColor("#BD00FF") -> R.id.ivDeepPurple
            Color.parseColor("#FF00F4") -> R.id.ivPurple
            else -> R.id.ivRed
        }
        refreshBg(mSelectColorId, false, dismiss = false)
        return this
    }
}
