package com.cloudroom.whiteboardkt

import android.content.Context
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.RecyclerView
import com.cloudroom.cloudroomvideosdk.model.BoardInfo
import com.google.gson.Gson
import java.lang.Exception

/**
 * Created by zjw on 2022/8/29.
 */
open class WbSelectAdapter(val context: Context) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private val mDataList = arrayListOf<BoardInfo>()
    private var mCurWId = ""
    private var mCloseListener: (String) -> Unit = {}
    private var mSelectListener: (String) -> Unit = {}

    fun setCloseListener(listener: (String) -> Unit): WbSelectAdapter {
        mCloseListener = listener
        return this
    }

    fun setSelectListener(listener: (String) -> Unit): WbSelectAdapter {
        mSelectListener = listener
        return this
    }

    fun setData(list: ArrayList<BoardInfo>, curId: String): WbSelectAdapter {
        mDataList.clear()
        mDataList.addAll(list)
        mCurWId = curId
        notifyDataSetChanged()
        return this
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return WbSelectHolder(LayoutInflater.from(context).inflate(R.layout.item_wb, parent, false))
    }

    override fun getItemCount(): Int {
        return mDataList.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        (holder as WbSelectHolder).setData(mDataList[position])
    }

    inner class WbSelectHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        private var llName: ConstraintLayout = itemView.findViewById(R.id.llName)
        private var tvName: TextView = itemView.findViewById(R.id.tvName)
        private var ivClose: ImageView = itemView.findViewById(R.id.ivClose)

        fun setData(wbdescV2: BoardInfo) {
            if (wbdescV2.boardID == mCurWId) {
                itemView.setBackgroundColor(Color.parseColor("#F0F0F0"))
            } else {
                itemView.background = null
            }
            try {
                tvName.text = Gson().fromJson(wbdescV2.extInfo,
                    WBCreateInfo::class.java).name
            }catch (e:Exception){
                e.printStackTrace()
            }
            ivClose.setOnClickListener { mCloseListener(wbdescV2.boardID) }
            llName.setOnClickListener { mSelectListener(wbdescV2.boardID) }
        }
    }

}