package com.cloudroom.whiteboardkt

import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.view.Gravity
import android.view.WindowManager
import android.widget.ImageView
import com.cloudroom.cloudroomvideosdk.model.BoardViewAttr
import kotlinx.android.synthetic.main.dialog_debug.*

/**
 * Created by zjw on 2022/10/14.
 */
class DebugDialog(context: Context) : Dialog(context) {

    private var mViewAttr: BoardViewAttr? = null
    private var dismissListener: (BoardViewAttr) -> Unit = {}

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.dialog_debug)
        window?.setBackgroundDrawableResource(android.R.color.transparent)
        ivAllow.setOnClickListener {
            btnClick(ivAllow)
        }
        ivAsyncPage.setOnClickListener {
            btnClick(ivAsyncPage)
        }
        ivFollowPage.setOnClickListener {
            btnClick(ivFollowPage)
        }
        ivAsyncScale.setOnClickListener {
            btnClick(ivAsyncScale)
        }
        ivFollowScale.setOnClickListener {
            btnClick(ivFollowScale)
        }
        refreshState()
    }

    fun setData(viewAttr: BoardViewAttr): DebugDialog {
        mViewAttr = viewAttr
        return this
    }

    fun setDismissListener(listener: (BoardViewAttr) -> Unit): DebugDialog {
        dismissListener = listener
        return this
    }

    private fun btnClick(iv: ImageView) {
        mViewAttr?.apply {
            when (iv) {
                ivAllow -> {
                    readOnly = !readOnly
                    refreshBtn(ivAllow, !readOnly)
                }
                ivAsyncPage -> {
                    asyncPage = !asyncPage
                    refreshBtn(ivAsyncPage, asyncPage)
                }
                ivFollowPage -> {
                    followPage = !followPage
                    refreshBtn(ivFollowPage, followPage)
                }
                ivAsyncScale -> {
                    asyncScale = !asyncScale
                    refreshBtn(ivAsyncScale, asyncScale)
                }
                ivFollowScale -> {
                    followScale = !followScale
                    refreshBtn(ivFollowScale, followScale)
                }
            }
        }
    }

    private fun refreshState() {
        mViewAttr?.apply {
            refreshBtn(ivAllow, !readOnly)
            refreshBtn(ivAsyncPage, asyncPage)
            refreshBtn(ivFollowPage, followPage)
            refreshBtn(ivAsyncScale, asyncScale)
            refreshBtn(ivFollowScale, followScale)
        }
    }

    private fun refreshBtn(iv: ImageView, open: Boolean) {
        if (open) {
            iv.setImageResource(R.mipmap.switch_on)
        } else {
            iv.setImageResource(R.mipmap.switch_off)

        }
    }

    override fun show() {
        super.show()
        val layoutParams = window!!.attributes
        layoutParams.gravity = Gravity.RIGHT
        layoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT
        layoutParams.height = WindowManager.LayoutParams.MATCH_PARENT
        window!!.decorView.setPadding(0, 0, 0, 0)
        window!!.attributes = layoutParams
    }

    override fun dismiss() {
        super.dismiss()
        mViewAttr?.apply {
            dismissListener(this)
        }
    }
}