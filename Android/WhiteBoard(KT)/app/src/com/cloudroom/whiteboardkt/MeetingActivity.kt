package com.cloudroom.whiteboardkt

import android.annotation.SuppressLint
import android.content.res.Configuration
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.os.Message
import android.text.TextUtils
import android.util.Log
import android.view.*
import android.widget.*
import androidx.constraintlayout.widget.ConstraintLayout
import com.cloudroom.cloudroomvideosdk.*
import com.cloudroom.cloudroomvideosdk.model.*
import com.cloudroom.tool.AndroidTool
import com.examples.common.VideoSDKHelper
import com.examples.tool.DrawableUtils
import com.examples.tool.UITool
import com.google.gson.Gson
import kotlinx.android.synthetic.main.activity_meeting.*

/**
 * Created by zjw on 2022/5/7.
 */
open class MeetingActivity : BaseActivity(), Handler.Callback {

    companion object {
        var mMeetID = 0
        var mBCreateMeeting = false
        private const val TAG = "MeetingActivity"
    }

    private var mToolbarContainer: LinearLayout? = null
    private var mRgToolbar: RadioGroup? = null
    private var mRgToolbar2: RadioGroup? = null
    private var mCurSelectId = R.id.btnPen
    private var mSelectDrawStyle = WB_SHAPE_TYPE.SHAPE_PEN
    private var mBtnPen: RadioButton? = null
    private var mBtnPenStyle: RadioButton? = null
    private var mBtnRevoke: RadioButton? = null
    private var mBtnRecover: RadioButton? = null
    private var mLlCreate: LinearLayout? = null
    private var mLlBtn: LinearLayout? = null
    private val mViewAttrMap = hashMapOf<String, BoardViewAttr>()

    @SuppressLint("ClickableViewAccessibility")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContentView(R.layout.activity_meeting)
        if (mMeetID <= 0 && !mBCreateMeeting) {
            finish()
            return
        }
        initViews()

        if (!initData()) {
            finish()
            return
        }
        CloudroomVideoMeeting.getInstance().registerCallback(mMeetingCallback)
        CloudroomVideoMgr.getInstance().registerCallback(mMgrCallback)
        mMainHandler.post { showEntering() }
    }

    private fun initViews() {
        mLlCreate = findViewById(R.id.llNewWb)
        mLlBtn = findViewById(R.id.llBtn)
        mToolbarContainer = findViewById(R.id.toolbarContainer)
        mRgToolbar = findViewById(R.id.rgToolbar)
        mRgToolbar2 = findViewById(R.id.rgToolbar2)
        mBtnPen = findViewById(R.id.btnPen)
        mBtnPenStyle = findViewById(R.id.btnPenStyle)
        mBtnRecover = findViewById(R.id.btnRecover)
        mBtnRevoke = findViewById(R.id.btnRevoke)
        mToolbarContainer?.background = DrawableUtils.getShadowDrawable(
            this, Color.WHITE, 5, 6, 6
        )
        refreshToolLayout(resources.configuration)
        mRgToolbar?.setOnCheckedChangeListener { _, i ->
            onCheckedChange(i)
        }
        mRgToolbar2?.setOnCheckedChangeListener { _, i ->
            onCheckedChange(i)
        }
        setChecked(mCurSelectId)
        mBtnRevoke?.isEnabled = false
        mBtnRecover?.isEnabled = false

        boardview.setBoardViewCallback(mBoardViewCallback)
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        refreshToolLayout(newConfig)
    }

    private var mBoardViewCallback = object : BoardView.BoardViewCallback {

        override fun notifyBoardCurPageChanged(curPage: Int, operatorUserID: String) {

        }

        override fun notifyRedoEnableChanged(bEnable: Boolean) {
            mBtnRecover?.isEnabled = bEnable
            val drawId = if (bEnable) {
                R.mipmap.recover_black
            } else {
                R.mipmap.recover_gray
            }
            val drawable = resources.getDrawable(drawId)
            drawable.setBounds(
                0, 0, AndroidTool.dip2px(this@MeetingActivity, 40f),
                AndroidTool.dip2px(this@MeetingActivity, 40f)
            )
            mBtnRecover?.setCompoundDrawables(null, drawable, null, null)
        }

        override fun notifyUndoEnableChanged(bEnable: Boolean) {
            mBtnRevoke?.isEnabled = bEnable
            val drawId = if (bEnable) {
                R.mipmap.revoke_black
            } else {
                R.mipmap.revoke_gray
            }
            val drawable = resources.getDrawable(drawId)
            drawable.setBounds(
                0, 0, AndroidTool.dip2px(this@MeetingActivity, 40f),
                AndroidTool.dip2px(this@MeetingActivity, 40f)
            )
            mBtnRevoke?.setCompoundDrawables(null, drawable, null, null)
        }

        override fun notifyViewScaleChanged(scale: Float) {

        }

        override fun notifyMarkException(exType: MarkException) {
            if (exType == MarkException.TypeSingleLineLimt) {
                Toast.makeText(this@MeetingActivity, "单笔标注超长截断", Toast.LENGTH_SHORT).show()
            } else if (exType == MarkException.TypeSinglePageLimit) {
                Toast.makeText(this@MeetingActivity, "单页标注已达最大无法再标注", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun onCheckedChange(i: Int) {
        if (i == R.id.btnRevoke || i == R.id.btnRecover || i == R.id.btnEmpty || i == R.id.btnSave) {
            setChecked(mCurSelectId)
            return
        }
        findViewById<RadioButton>(mCurSelectId)?.background = null
        findViewById<RadioButton>(i)?.setBackgroundColor(Color.parseColor("#e6e6e6"))
        mCurSelectId = i
        setChecked(mCurSelectId)
        var mode = mSelectDrawStyle
        when (i) {
            R.id.btnPitch -> mode = WB_SHAPE_TYPE.SHAPE_PITCH
            R.id.btnEraser -> mode = WB_SHAPE_TYPE.SHAPE_ERASER
            R.id.btnImg -> mode = WB_SHAPE_TYPE.SHAPE_IMAGE
            R.id.btnMove -> mode = WB_SHAPE_TYPE.SHAPE_MOVE
            R.id.btnText -> mode = WB_SHAPE_TYPE.SHAPE_TEXT
        }
        boardview.boardViewToolType = mode
    }

    private fun setChecked(id: Int) {
        mRgToolbar?.check(id)
        mRgToolbar2?.check(id)
    }

    private fun initData(): Boolean {
        if (mBCreateMeeting) {
            createMeeting()
            return true
        }
        if (mMeetID <= 0) {
            return false
        }
        enterMeeting(mMeetID)
        return true
    }

    private fun refreshToolLayout(config: Configuration) {
        mToolbarContainer?.post {
            val toolParams = ConstraintLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            if (config.orientation == Configuration.ORIENTATION_LANDSCAPE) {
                mToolbarContainer?.orientation = LinearLayout.HORIZONTAL
                toolParams.height = rgToolbar.height + 20
                rgToolbar.setPadding(0, 0, 0, 0)
            } else {
                mToolbarContainer?.orientation = LinearLayout.VERTICAL
                rgToolbar.setPadding(0, AndroidTool.dip2px(this, 10f), 0, 0)
            }
            toolParams.rightToRight = R.id.container
            toolParams.topToBottom = R.id.titleBar
            toolParams.bottomToBottom = R.id.container
            toolParams.rightMargin = AndroidTool.dip2px(this, 5f)
            mToolbarContainer?.layoutParams = toolParams
        }
    }

    // 创建房间
    private fun createMeeting() {
        // 创建房间
        CloudroomVideoMgr.getInstance().createMeeting(TAG)
    }

    // 进入房间
    private fun enterMeeting(meetID: Int) {
        // 进入房间
        CloudroomVideoMeeting.getInstance().enterMeeting(meetID)
        val tvID = findViewById<TextView>(R.id.tvID)
        tvID.text = "房间ID：$meetID"
    }

    private fun showEntering() {
        UITool.showProcessDialog(this, getString(R.string.entering))
    }

    fun onToolbarClick(v: View) {
        when (v.id) {
            R.id.btnPen -> {
                mBtnPen?.apply {
                    val root: View =
                        View.inflate(this.context, R.layout.pop_draw_style, null)
                    val drawStylePop =
                        DrawStylePop(
                            root
                        )
                    root.measure(
                        View.MeasureSpec.UNSPECIFIED,
                        View.MeasureSpec.UNSPECIFIED
                    )
                    drawStylePop.setCurSelect(mSelectDrawStyle)
                        .setOnselectListener {
                            val drawId = when (it) {
                                WB_SHAPE_TYPE.SHAPE_ARROW -> R.mipmap.style_arrow
                                WB_SHAPE_TYPE.SHAPE_LINE -> R.mipmap.style_line
                                WB_SHAPE_TYPE.SHAPE_RECT -> R.mipmap.style_rect
                                WB_SHAPE_TYPE.SHAPE_ELLIPSE -> R.mipmap.style_circle
                                else -> R.mipmap.style_pen
                            }
                            val drawable = resources.getDrawable(drawId)
                            drawable.setBounds(
                                0, 0, AndroidTool.dip2px(this@MeetingActivity, 30f),
                                AndroidTool.dip2px(this@MeetingActivity, 30f)
                            )
                            mBtnPen?.setCompoundDrawables(null, drawable, null, null)
                            mSelectDrawStyle = it
                            boardview.boardViewToolType = it
                        }
                        .showAsDropDown(
                            this,
                            -(root.measuredWidth + width + 20),
                            -height
                        )
                }
            }
            R.id.btnPenStyle -> {
                mBtnPenStyle?.apply {
                    val root: View =
                        View.inflate(this.context, R.layout.pop_pen_style, null)
                    val penStylePop =
                        PenStylePop(
                            root
                        )
                    root.measure(
                        View.MeasureSpec.UNSPECIFIED,
                        View.MeasureSpec.UNSPECIFIED
                    )
                    penStylePop.setSelectListener {
                        val styleId = when (boardview.boardViewToolAttr.color) {
                            Color.parseColor("#F0F0F0")
                            -> R.drawable.element_color_gray_checked
                            Color.parseColor("#7B7B7B")
                            -> R.drawable.element_color_black_checked
                            Color.parseColor("#FF6B00")
                            -> R.drawable.element_color_orange_checked
                            Color.parseColor("#FFB800")
                            -> R.drawable.element_color_yellow_checked
                            Color.parseColor("#68DB00")
                            -> R.drawable.element_color_green_checked
                            Color.parseColor("#00DDFF")
                            -> R.drawable.element_color_blue_checked
                            Color.parseColor("#007FFF")
                            -> R.drawable.element_color_deepblue_checked
                            Color.parseColor("#BD00FF")
                            -> R.drawable.element_color_deeppurple_checked
                            Color.parseColor("#FF00F4")
                            -> R.drawable.element_color_purple_checked
                            else -> R.drawable.element_color_red_checked
                        }
                        val drawable = resources.getDrawable(styleId)
                        drawable.setBounds(
                            0,
                            0,
                            AndroidTool.dip2px(this@MeetingActivity, 40f),
                            AndroidTool.dip2px(this@MeetingActivity, 40f)
                        )
                        mBtnPenStyle?.setCompoundDrawables(null, drawable, null, null)
                    }
                        .setCurSelect(boardview.boardViewToolAttr)
                        .showAsDropDown(
                            this,
                            -(root.measuredWidth + width + 20),
                            -height
                        )
                }
            }
            R.id.btnEmpty ->
                UITool.showConfirmDialog(this, "温馨提示\n" +
                        "确定要清除所有内容吗",
                    object : UITool.ConfirmDialogCallback {
                        override fun onOk() {
                            boardview.clearCurPage()
                        }

                        override fun onCancel() {}
                    })

            R.id.btnRevoke -> {
                boardview.undo()
            }
            R.id.btnRecover -> {
                boardview.redo()
            }
            /*R.id.btnSave -> {
                boardview.saveWBImg()
            }*/
        }
    }

    private val mMgrCallback: CRMgrCallback = object : CRMgrCallback() {
        override fun lineOff(sdkErr: CRVIDEOSDK_ERR_DEF) {
            VideoSDKHelper.getInstance().showToast(R.string.sys_dropped)
            exitMeeting()
        }

        override fun createMeetingFail(sdkErr: CRVIDEOSDK_ERR_DEF, cookie: String) {

            // 创建房间失败，提示并退出界面
            VideoSDKHelper.getInstance().showToast(
                R.string.create_meet_fail,
                sdkErr
            )
            UITool.hideProcessDialog(this@MeetingActivity)
            finish()
        }

        override fun createMeetingSuccess(meetInfo: MeetInfo, cookie: String) {

            // 创建房间成功直接进入房间
            enterMeeting(meetInfo.ID)
        }
    }

    private val mMeetingCallback: CRMeetingCallback = object : CRMeetingCallback() {
        /**
         * 进入房间结果
         *
         * @param code
         * 结果
         */
        override fun enterMeetingRslt(code: CRVIDEOSDK_ERR_DEF) {
//            Log.d("eeeeeeee", "enterMeetingRslt======meeting")
            UITool.hideProcessDialog(this@MeetingActivity)
            if (code != CRVIDEOSDK_ERR_DEF.CRVIDEOSDK_NOERR) {
                VideoSDKHelper.getInstance().showToast(
                    R.string.enter_fail,
                    code
                )
                exitMeeting()
                return
            }
            onEnterMeeting()
            Toast.makeText(this@MeetingActivity, "成功进入房间", Toast.LENGTH_SHORT).show()
        }

        override fun notifyInitBoardList(boardIDList: MutableList<String>?) {
//            println("eeeeee====notifyInitBoardList====meeting")

            val boardID = CloudroomVideoMeeting.getInstance().currentBoard
            if (boardID.isNullOrEmpty()) {
                return
            }
            updateTitle(boardID)
            boardview.setBoardID(boardID, getCurBoardViewAttr(boardID))
        }


        override fun notifyCreateBoard(boardInfo: BoardInfo, opId: String) {
//            println("eeeeee====notifyCreateBoard====meeting")
            if (opId == CloudroomVideoMeeting.getInstance().myUserID) {
                CloudroomVideoMeeting.getInstance().currentBoard = boardInfo.boardID
                boardview.setBoardID(boardInfo.boardID, getCurBoardViewAttr(boardInfo.boardID))
                updateTitle(boardInfo.boardID)
            }
        }

        override fun notifyCloseBoard(boarId: String?, opId: String?) {
//            println("eeeeee====notifyCloseBoard====meeting")
            updateTitle(CloudroomVideoMeeting.getInstance().currentBoard)
            val allBoard = CloudroomVideoMeeting.getInstance().allBoard
            if (allBoard.size < 1) {
                boardview.setBoardID("", getCurBoardViewAttr(""))
            }
        }

        override fun notifyCurrentBoard(boarId: String, opId: String) {
//            println("eeeeee====notifyCurrentBoard====meeting==$wId===$opId")
            if (boarId.isNotEmpty()) {
                updateTitle(boarId)
                if (!mViewAttrMap.containsKey(boarId)) {
                    val newAttr =
                        BoardViewAttr()
                    mViewAttrMap[boarId] = newAttr
                }
                boardview.setBoardID(boarId, getCurBoardViewAttr(boarId))
                setChecked(R.id.btnPen)
            }
        }

        override fun meetingDropped(reason: CRVIDEOSDK_MEETING_DROPPED_REASON) {
            VideoSDKHelper.getInstance().showToast(R.string.sys_dropped)
            exitMeeting()
        }

        override fun meetingStopped() {
            VideoSDKHelper.getInstance().showToast(R.string.meet_stopped)
            exitMeeting()
        }

//        override fun notifyMarkException(ex: String) {
//            Toast.makeText(this@MeetingActivity, ex, Toast.LENGTH_SHORT).show()
//        }
    }

    private fun getCurBoardViewAttr(boardID: String): BoardViewAttr {
        return if (mViewAttrMap.containsKey(boardID)) {
            mViewAttrMap[boardID]!!
        } else {
            BoardViewAttr()
        }
    }

    override fun handleMessage(msg: Message): Boolean {
        when (msg.what) {
            else -> {
            }
        }
        return false
    }

    var mMainHandler = Handler(this)

    private fun exitMeeting() {
        // 离开房间
        CloudroomVideoMeeting.getInstance().exitMeeting()
        finish()
    }

    private fun showExitDialog() {
        UITool.showConfirmDialog(this, "退出房间",
            object : UITool.ConfirmDialogCallback {
                override fun onOk() {
                    exitMeeting()
                }

                override fun onCancel() {}
            })
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        return if (keyCode == KeyEvent.KEYCODE_BACK) {
            true
        } else super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            showExitDialog()
            return true
        }
        return super.onKeyUp(keyCode, event)
    }

    // 成功进入房间
    private fun onEnterMeeting() {
    }

    private fun updateTitle(boardID: String) {
        val tvTitle = findViewById<TextView>(R.id.tvTitle)
        var name = "";
        try {
            var extInfo = CloudroomVideoMeeting.getInstance().getBoardInfo(boardID).extInfo
            if (!TextUtils.isEmpty(extInfo)) {
                name = Gson().fromJson(
                    extInfo,
                    WBCreateInfo::class.java
                ).name
            }
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        } finally {
            tvTitle.text = name
        }
    }

    fun onViewClick(v: View) {
        when (v.id) {
            R.id.tvExit -> showExitDialog()
            R.id.llTitle -> {
                WbSelectDialog(this)
                    .setCloseListener { CloudroomVideoMeeting.getInstance().closeBoard(it) }
                    .setSelectListener {
                        boardview.setBoardID(it, getCurBoardViewAttr(it))
                        CloudroomVideoMeeting.getInstance().currentBoard = it
                        updateTitle(it)
                    }
                    .setData(
                        CloudroomVideoMeeting.getInstance().allBoard,
                        CloudroomVideoMeeting.getInstance().currentBoard
                    )
                    .show()
            }
            R.id.llNewWb -> {
                if (CloudroomVideoMeeting.getInstance().allBoard.size > 4) {
                    Toast.makeText(this, "超过上限", Toast.LENGTH_SHORT).show()
                } else {
                    val createExInfo = WBCreateInfo()

                    var index = CloudroomVideoMeeting.getInstance().allBoard.size + 1
                    var title = CloudroomVideoMeeting.getInstance().myUserID + "的白板" + index
                    createExInfo.name = title
                    var extInfo = Gson().toJson(createExInfo)

                    CloudroomVideoMeeting.getInstance().createWhiteBoard(1280, 720, 1, PageMode.PageModeFullPage, extInfo)
                }
            }
            R.id.tvDebug -> {
                val curWbId = CloudroomVideoMeeting.getInstance().currentBoard
                if (curWbId.isNotEmpty()) {
                    DebugDialog(this@MeetingActivity).setData(boardview.boardViewAttr)
                        .setDismissListener {
                            mViewAttrMap[curWbId] = it
                        }
                        .show()
                }
            }
            else -> {
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        CloudroomVideoMeeting.getInstance().exitMeeting()
        CloudroomVideoMeeting.getInstance()
            .unregisterCallback(mMeetingCallback)
        CloudroomVideoMgr.getInstance().unregisterCallback(mMgrCallback)
    }

}