package com.cloudroom.whiteboardkt

import android.graphics.Color
import android.view.View
import android.widget.ImageView
import android.widget.PopupWindow
import com.cloudroom.cloudroomvideosdk.model.WB_SHAPE_TYPE
import com.examples.tool.DrawableUtils
import com.examples.tool.Tools


/**
 * Created by zjw on 2022/8/8.
 */
class DrawStylePop(contentView: View) :
    PopupWindow(
        contentView, Tools.dp2px(contentView.context, 260),
        Tools.dp2px(contentView.context, 134)
    ) {

    private var mCurShapeType = WB_SHAPE_TYPE.SHAPE_PEN
    private var mSelectListener: (WB_SHAPE_TYPE) -> Unit = {}
    private var ivPen: ImageView? = null
    private var ivRect: ImageView? = null
    private var ivCircle: ImageView? = null
    private var ivLine: ImageView? = null
    private var ivArrow: ImageView? = null

    private var clickListener = View.OnClickListener { v ->
        when (v.id) {
            R.id.ivPen -> mCurShapeType = WB_SHAPE_TYPE.SHAPE_PEN
            R.id.ivRect -> mCurShapeType = WB_SHAPE_TYPE.SHAPE_RECT
            R.id.ivCircle -> mCurShapeType = WB_SHAPE_TYPE.SHAPE_ELLIPSE
            R.id.ivLine -> mCurShapeType = WB_SHAPE_TYPE.SHAPE_LINE
            R.id.ivArrow -> mCurShapeType = WB_SHAPE_TYPE.SHAPE_ARROW
        }
//        WhiteBoardHelper.getInstance().curShapeType = mCurShapeType
//        WhiteBoardHelper.getInstance().lastShapeType = mCurShapeType
        mSelectListener(mCurShapeType)
        dismiss()
    }

    init {
        ivPen = contentView.findViewById(R.id.ivPen)
        ivRect = contentView.findViewById(R.id.ivRect)
        ivCircle = contentView.findViewById(R.id.ivCircle)
        ivLine = contentView.findViewById(R.id.ivLine)
        ivArrow = contentView.findViewById(R.id.ivArrow)
        ivPen?.setOnClickListener(clickListener)
        ivRect?.setOnClickListener(clickListener)
        ivCircle?.setOnClickListener(clickListener)
        ivLine?.setOnClickListener(clickListener)
        ivArrow?.setOnClickListener(clickListener)
        isFocusable = true
        isTouchable = true
        contentView.background = DrawableUtils.getShadowDrawable(
            contentView.context, Color.WHITE, 10, 6, 6
        )

    }

    fun setOnselectListener(listener: (WB_SHAPE_TYPE) -> Unit): DrawStylePop {
        mSelectListener = listener
        return this
    }

    fun setCurSelect(shapetypeV2: WB_SHAPE_TYPE): DrawStylePop {
        mCurShapeType = shapetypeV2
        when (mCurShapeType) {
            WB_SHAPE_TYPE.SHAPE_PEN -> {
                ivPen?.setBackgroundColor(Color.parseColor("#e9e9e9"))
            }
            WB_SHAPE_TYPE.SHAPE_RECT -> {
                ivRect?.setBackgroundColor(Color.parseColor("#e9e9e9"))
            }
            WB_SHAPE_TYPE.SHAPE_ELLIPSE -> {
                ivCircle?.setBackgroundColor(Color.parseColor("#e9e9e9"))
            }
            WB_SHAPE_TYPE.SHAPE_LINE -> {
                ivLine?.setBackgroundColor(Color.parseColor("#e9e9e9"))
            }
            WB_SHAPE_TYPE.SHAPE_ARROW -> {
                ivArrow?.setBackgroundColor(Color.parseColor("#e9e9e9"))
            }
            else -> {
            }
        }
        return this
    }


}