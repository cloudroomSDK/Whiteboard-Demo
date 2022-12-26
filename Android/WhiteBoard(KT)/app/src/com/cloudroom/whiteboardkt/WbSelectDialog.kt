package com.cloudroom.whiteboardkt

import android.app.Dialog
import android.content.Context
import android.os.Bundle
import android.view.Gravity
import android.view.WindowManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cloudroom.cloudroomvideosdk.model.BoardInfo


/**
 * Created by zjw on 2022/8/29.
 */
open class WbSelectDialog(context: Context) : Dialog(context) {

    private val mDescList = arrayListOf<BoardInfo>()
    private var mRvList: RecyclerView? = null
    private var mCurWbId = ""

    private var mCloseListener: (String) -> Unit = {}
    private var mSelectListener: (String) -> Unit = {}

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.dialog_wb_select)
        mRvList = findViewById(R.id.rvList)
        window?.setBackgroundDrawableResource(android.R.color.transparent)
        mRvList?.layoutManager = LinearLayoutManager(context)
        val adapter = WbSelectAdapter(context)
        mRvList?.adapter = adapter
        adapter
            .setCloseListener {
                mCloseListener(it)
                dismiss()
            }
            .setSelectListener {
                mSelectListener(it)
                dismiss()
            }
            .setData(mDescList, mCurWbId)
    }

    fun setCloseListener(listener: (String) -> Unit): WbSelectDialog {
        mCloseListener = listener
        return this
    }

    fun setSelectListener(listener: (String) -> Unit): WbSelectDialog {
        mSelectListener = listener
        return this
    }

    fun setData(list: ArrayList<BoardInfo>, wId: String): WbSelectDialog {
        mCurWbId = wId
        mDescList.clear()
        mDescList.addAll(list)
        return this
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
}