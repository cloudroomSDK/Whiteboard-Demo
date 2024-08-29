var app = new Vue({
  el: '#app',
  data: {
    sdkver: '', // SDK版本
    isInitSDK: false, // SDK是否已初始化
    isLogin: false, // SDK是否已登录鉴权
    loginSetHide: true, // 是否显示登陆设置界面
    mainPage: 'login', // 主界面 login board
    nicknameInput: '', // 登录界面昵称输入
    // SDK登陆鉴权相关参数
    loginData: {
      nickname: '', // 昵称
      userID: '', // 用户唯一ID（UID）
      authType: '', // 鉴权方式（appID鉴权或token鉴权）
      // protocol: '', // 流媒体传输协议（UDP/TCP）纯白板用不上，缺省即可
      server: '', // SDK服务器地址
      appID: '', // SDK鉴权appID（appID鉴权方式）
      appSecret: '', // SDK鉴权appSecret（appID鉴权方式）
      token: '', // SDK鉴权token（token鉴权方式）
      userAuthCode: '', // 第三方鉴权参数（需先在管理后台设置，非必须）
    },
    // 房间内相关参数
    roomData: {
      roomID: '', // 房间号
    },
    isMeeting: false, // 是否在房间中
    curBoardID: '', // 当前的白板ID
    boardList: [], // 所有白板
    defaultAttr: {
      readOnly: false, // 是否只读
      asyncPage: true, // 是否同步发送翻页
      followPage: true, // 是否跟随翻页
      asyncScale: true, // 是否同步发送缩放
      followScale: true, // 是否跟随缩放
      pageMargin: 10, // 连页模式页间隙
      showRange: false, // 是否显示图元虚线外框
    },
    defaultToolAttr: {
      lineWidth: 2, // 线宽
      // lineStyle: 1, // 线型
      color: 'rgba(0,127,255,1)', // 颜色
      fontSize: 20, // 文字字体大小
      // fontFamily: 'sans-serif', // 文字字体
      fontWeight: 'normal', // 普通normal、加粗bold
      fontStyle: 'normal', // 是否斜体 普通normal、斜体italic
      fontUnderLine: false, // 文字是否下划线
      fontBackGroundColor: 'rgba(210,221,234,1)', // 文字背景色
    },
    curView: {
      boardView: null, // 白板view
      curPage: 0, // 当前页
      totalPage: 0, // 总页数
      scale: 100, // 当前缩放比
      redo: false, // 是否允许redo
      undo: false, // 是否允许undo
      toolType: 1, // 工具类型
      attr: {}, // view属性
      toolAttr: {}, // 工具属性
    },
    toolTypeButtonClass: 'pencil', // 工具类型按钮
    showToolType: false, // 是否显示工具类型选择
    showColorBox: false, // 是否显示颜色/线宽选择
    showFontSetBox: false, // 是否显示文字设置
    showSettingBox: false, // 是否显示设置面板
    cloudMixers: [], // 云端录制混图器
    recordStateText: '录制',
  },
  computed: {
    colorClass() {
      let returnVal = '';
      switch (this.curView.toolAttr.color) {
        case 'rgba(240,240,240,1)':
          returnVal = '_F0F0F0 ';
          break;
        case 'rgba(123,123,123,1)':
          returnVal = '_7B7B7B ';
          break;
        case 'rgba(236,80,80,1)':
          returnVal = '_FF0000 ';
          break;
        case 'rgba(255,107,0,1)':
          returnVal = '_FF6B00 ';
          break;
        case 'rgba(255,184,0,1)':
          returnVal = '_FFB800 ';
          break;
        case 'rgba(104,219,0,1)':
          returnVal = '_68DB00 ';
          break;
        case 'rgba(18,223,255,1)':
          returnVal = '_00DDFF ';
          break;
        case 'rgba(0,127,255,1)':
          returnVal = '_007FFF ';
          break;
        case 'rgba(189,0,255,1)':
          returnVal = '_BD00FF ';
          break;
        case 'rgba(255,0,244,1)':
          returnVal = '_FF00F4 ';
          break;
      }
      return returnVal;
    },
  },
  watch: {
    curBoardID() {
      // console.log(`=====>>> curBoardID changed: ${this.curBoardID}`);
      this.$nextTick(() => {
        if (!this.curBoardID) {
          if (!!document.querySelector('#boardViewBox')) document.querySelector('#boardViewBox').innerHTML = '';
          return;
        }
        const boardItem = this.boardList.find((item) => item.boardID == this.curBoardID);
        this.curView.boardView = boardItem.view;
        window.__view = this.curView.boardView;
        // SDK接口（白板view)：获取白板view当前工具类型     SDK接口（白板view)：设置白板view的工具类型
        if (this.curView.boardView.getToolType() == 0) this.setToolType(1);
        this.curView.totalPage = boardItem.pageCount;
        // SDK接口（白板view）：获取白板view的当前页
        this.curView.curPage = this.curView.boardView.getCurPage();
        // SDK接口（白板view）：获取白板view当前的属性
        this.curView.attr = this.curView.boardView.getAttr();
        // SDK接口（白板view）：获取白板view当前的工具类型
        this.curView.toolType = this.curView.boardView.getToolType();
        // SDK接口（白板view）：获取白板view当前的工具属性
        this.curView.toolAttr = this.curView.boardView.getToolAttr();
        // SDK接口（白板view）：获取白板view当前的缩放比
        this.curView.scale = this.curView.boardView.getScale();
        // SDK接口（白板view）：获取白板view当前是否允许撤销
        this.curView.undo = this.curView.boardView.getUndoEnableState();
        // SDK接口（白板view）：获取白板view当前是否允许重做
        this.curView.redo = this.curView.boardView.getRedoEnableState();
        // SDK接口（白板view）：获取白板view对应的DOM组件
        let viewDom = this.curView.boardView.handler();
        document.querySelector('#boardViewBox').innerHTML = '';
        document.querySelector('#boardViewBox').appendChild(viewDom);
        // SDK接口（白板view）：重置白板view的大小
        // this.curView.boardView.resize('业务层主动调用');
      });
    },
    nicknameInput() {
      this.loginData.nickname = this.nicknameInput;
      this.loginData.userID = this.nicknameInput + `_${Math.round(Math.random() * 10000)}`;
    },
    showToolType() {
      if (this.showToolType) {
        this.showColorBox = false;
        this.showFontSetBox = false;
      }
    },
    showColorBox() {
      if (this.showColorBox) {
        this.showToolType = false;
        this.showFontSetBox = false;
      }
    },
    showFontSetBox() {
      if (this.showFontSetBox) {
        this.showToolType = false;
        this.showColorBox = false;
      }
    },
    'curView.toolType'(newType, oldType) {
      // SDK接口（白板view）：设置白板view的鼠标样式
      switch (newType) {
        case 1:
          this.toolTypeButtonClass = 'pencil';
          this.curView.boardView.setCursor(`url(../whiteBoardDemo/imgs/鼠标光标-铅笔.cur),default`);
          break;
        case 2:
          this.toolTypeButtonClass = 'straightLine';
          break;
        case 3:
          this.toolTypeButtonClass = 'squareLine';
          break;
        case 4:
          this.toolTypeButtonClass = 'roundLine';
          break;
        case 5:
          this.toolTypeButtonClass = 'arrows';
          break;
        case 6:
          this.curView.boardView.setCursor('text');
          break;
        case 8:
          this.curView.boardView.setCursor(`url(../whiteBoardDemo/imgs/鼠标光标-选择.cur),default`);
          break;
        case 9:
          this.curView.boardView.setCursor(`url(../whiteBoardDemo/imgs/鼠标光标-橡皮擦.cur),default`);
          break;
        case 10:
          this.curView.boardView.setCursor(`move`);
          break;
        case 11:
          this.toolTypeButtonClass = 'squareFill';
          break;
        case 12:
          this.toolTypeButtonClass = 'roundFill';
          break;
        case 13:
          this.toolTypeButtonClass = 'pentacleLine';
          break;
        default:
          break;
      }
    },
  },
  created() {
    window.__CRKEY = 'CRDEMO';
    this.curView.attr = this.defaultAttr;
    this.curView.toolAttr = this.defaultToolAttr;

    // SDK接口：获取SDK版本号
    this.sdkver = CRVideo_GetSDKVersion();

    // 全局注册监听需要用到的通知或回调接口（promise类型的接口不需要）
    // SDK接口：回调 登录成功
    CRVideo_LoginSuccess.callback = this.loginSucess;
    // SDK接口：回调 登录失败
    CRVideo_LoginFail.callback = this.LoginFail;
    // SDK接口：通知 登录掉线（从呼叫系统掉线，未启用呼叫服务则不会触发）
    CRVideo_LineOff.callback = this.LineOff;
    // SDK接口：回调 房间创建成功
    CRVideo_CreateMeetingSuccess.callback = this.CreateMeetingSuccess;
    // SDK接口：回调 房间创建失败
    CRVideo_CreateMeetingFail.callback = this.CreateMeetingFail;
    // SDK接口：回调 进入房间的结果
    CRVideo_EnterMeetingRslt.callback = this.EnterMeetingRslt;
    // SDK接口：通知 从房间里面掉线了
    CRVideo_MeetingDropped.callback = this.MeetingDropped;
    // SDK接口：通知 房间已被结束
    CRVideo_MeetingStopped.callback = this.MeetingStopped;
    // SDK接口：通知 通知初始化白板列表
    CRBoard_NotifyInitBoardList.callback = this.NotifyInitBoardList;
    // SDK接口：通知 通知创建了新白板
    CRBoard_NotifyCreateBoard.callback = this.NotifyCreateBoard;
    // SDK接口：通知 通知关闭了某个白板
    CRBoard_NotifyCloseBoard.callback = this.NotifyCloseBoard;
    // SDK接口：通知 通知变更当前白板
    CRBoard_NotifyCurrentBoard.callback = this.NotifyCurrentBoard;
    // SDK接口：通知 通知白板缩放变化
    // CRBoard_NotifyBoardScale.callback = this.NotifyBoardScale;
    // SDK接口：通知 云端录制状态变化
    CRVideo_CloudMixerStateChanged.callback = this.CloudMixerStateChanged;
    // SDK接口：回调 启动源端录制失败
    CRVideo_CreateCloudMixerFailed.callback = this.CreateCloudMixerFailed;
    // SDK接口：通知 录制输出状态变化
    CRVideo_CloudMixerOutputInfoChanged.callback = this.CloudMixerOutputInfoChanged;

    // // 会议中关闭页面弹出提示确认
    // window.addEventListener('beforeunload', (e) => {
    //   if (this.isMeeting) {
    //     // 部分浏览器支持 event.preventDefault() + return 部分浏览器支持 event.returnValue
    //     const event = e || window.event;
    //     const message = '正在会议中，仍然关闭？';
    //     event.preventDefault();
    //     if (e) event.returnValue = message;
    //     // 注册一个耗时计算的方法，让页面关的慢一点，确保离开房间的消息能发出去，这里先注册方法
    //     window.__fib = function (n) {
    //       return n < 2 ? n : __fib(n - 1) + __fib(n - 2);
    //     };
    //     return message;
    //   }
    // });
    // 会议中确认关闭页面之后离开会议
    window.addEventListener('unload', (e) => {
      if (this.isMeeting) {
        // SDK接口：退出房间
        CRVideo_ExitMeeting();
        // SDK接口：退出登录
        CRVideo_Logout();
        // 做一个耗时计算，让页面关的慢一点，确保离开房间的消息能发出去，这里触发方法，一定是在接口调用完之后再触发
        window.__fib(40);
      }
    });

    document.addEventListener('click', () => {
      this.showToolType = false; // 是否显示工具类型选择
      this.showColorBox = false; // 是否显示颜色/线宽选择
      this.showFontSetBox = false; // 是否显示文字设置
      this.showSettingBox = false; // 是否显示设置面板
    });
  },
  mounted() {
    this.initLoginData();
  },
  methods: {
    // 初始化登陆参数
    initLoginData() {
      // 读取本地存储配置
      const storage = JSON.parse(localStorage.getItem('CRBoardDemo_PC_LOGIN')) || {};
      const nickname = sessionStorage.getItem('CRBoardDemo_PC_NICKNAME');
      // 昵称
      this.nicknameInput = nickname || `WEB用户${Math.floor(Math.random() * 8999) + 1000}`;
      // 鉴权方式
      this.loginData.authType = storage.authType ? storage.authType : '1';
      // 服务器地址
      this.loginData.server = storage.server ? storage.server : window.location.host;
      if (this.loginData.server.includes('127.0.0.1') || this.loginData.server.includes('localhost') || !this.loginData.server) this.loginData.server = `sdk.${window.__CRName}.com`;
      // 鉴权AppID
      this.loginData.appID = storage.appID ? storage.appID : '默认appID';
      // 鉴权AppSecret
      this.loginData.appSecret = storage.appSecret ? storage.appSecret : '默认appSecret';
      // 鉴权Token（鉴权方式为token鉴权）
      this.loginData.token = storage.token ? storage.token : '';
      // 第三方鉴权参数（未启用则为空）
      this.loginData.userAuthCode = storage.userAuthCode ? storage.userAuthCode : this.loginData.userAuthCode;
      // 房间号
      this.roomData.roomID = localStorage.getItem('CRBoardDemo_RoomID') || '';
    },
    // 点击登录设置重置按钮
    resetLoginData() {
      this.loginData.authType = '1';
      this.loginData.server = `sdk.${window.__CRName}.com`;
      this.loginData.appID = '默认appID';
      this.loginData.appSecret = '默认appSecret';
      this.loginData.token = '';
      this.loginData.userAuthCode = '';
    },
    // 重置相关数据
    resetData() {
      this.isMeeting = false; // 是否在房间中
      this.curBoardID = ''; // 当前的白板ID
      this.boardList = []; // 所有白板
      this.curView = {
        boardView: null, // 白板view（本demo只创建一个view，白板切换时设置对应的白板ID；您也可以每个白板创建一个对应的view）
        attr: this.defaultAttr,
        curPage: 0, // 当前页
        totalPage: 0, // 总页数
        scale: 100, // 当前缩放比
        redo: false, // 是否允许redo
        undo: false, // 是否允许undo
        toolType: 1, // 工具类型
        // 工具属性
        toolAttr: this.defaultToolAttr,
      };
      this.toolTypeButtonClass = 'pencil'; // 工具类型按钮
      this.showToolType = false; // 是否显示工具类型选择
      this.showColorBox = false; // 是否显示颜色/线宽选择
      document.querySelector('#boardViewBox').innerHTML = '';
    },
    // 点击进入房间按钮
    clickEnterBtn() {
      this.sdkLogin('enterBtn');
    },
    // 点击创建房间按钮
    clickCreateMeetBtn() {
      this.sdkLogin('createBtn');
    },
    // 初始化SDK
    initSDK() {
      return new Promise((resolve, reject) => {
        // SDK接口：设置SDK参数
        CRVideo_SetSDKParams({
          // isUploadLog: false,
          isCallSer: false, // 不启用呼叫服务
          isWebRTC: false, // 不启用音视频服务
        });
        // H5SDK只需要初始化一次，结束后无需反初始化
        // SDK接口：初始化SDK
        CRVideo_Init().then((res) => {
          this.isInitSDK = true;
          resolve();
        });
      });
    },
    // 点击登录设置的确定按钮
    clickConfirmBtn() {
      this.loginSetHide = true;
    },
    // 登陆
    sdkLogin(cookie) {
      if (cookie == 'enterBtn' || cookie == 'createBtn')
        this.loadingLayer = this.$loading({
          lock: true,
          text: '正在登录',
        });

      if (cookie.includes('reLogin'))
        this.loadingLayer = this.$loading({
          lock: true,
          text: '已掉线，正在重新登录',
        });

      if (this.isInitSDK) {
        // SDK接口：设置SDK服务器地址
        CRVideo_SetServerAddr(this.loginData.server);
        if (this.loginData.authType == '1') {
          // SDK接口：登陆SDK
          CRVideo_Login(this.loginData.appID, this.loginData.appSecret == '默认appSecret' ? this.loginData.appSecret : md5(this.loginData.appSecret), this.loginData.nickname, this.loginData.userID, this.loginData.userAuthCode, cookie);
        } else {
          // SDK接口：登陆SDK（Token鉴权）
          CRVideo_LoginByToken(this.loginData.token, this.loginData.nickname, this.loginData.userID, this.loginData.userAuthCode, cookie);
        }
      } else {
        this.initSDK().then(() => {
          this.sdkLogin(cookie);
        });
      }
    },
    // 登陆成功的处理
    loginSucess(userID, cookie) {
      console.log(`登录成功，userID:${userID}，cookie:${cookie}`);
      window.localStorage.setItem('CRBoardDemo_PC_LOGIN', JSON.stringify(this.loginData));
      window.sessionStorage.setItem('CRBoardDemo_PC_NICKNAME', this.loginData.nickname);
      this.loadingLayer.close();
      this.isLogin = true;
      if (cookie == 'enterBtn') this.enterMeet(this.roomData.roomID, 'enterBtn');
      if (cookie == 'createBtn') this.createMeet();
    },
    // 登录失败的处理
    LoginFail(sdkErr, cookie) {
      console.log(`登录失败，${sdkErr}, ${cookie}`);
      this.isLogin = false;

      if (!!cookie && cookie.includes('reLogin') && cookie.split('_')[1] <= 10) {
        clearTimeout(this.reLoginTimer ? this.reLoginTimer : -1);
        this.reLoginTimer = setTimeout(() => {
          this.sdkLogin(`reLogin_${++this.reLoginTimes}`);
        }, 2000);
        return;
      } else if (!!cookie && cookie.includes('reLogin') && cookie.split('_')[1] > 10) {
        MeetingDemo.alertLayer(`网络错误，多次尝试重登失败，您已掉线！请在网络恢复后刷新页面重新登录...`);
        this.$alert('网络错误，多次尝试重登失败，您已掉线！请在网络恢复后刷新页面重新登录...', '登陆失败', {
          confirmButtonText: '确定',
          callback: (action) => {
            // 回到登陆界面
            this.mainPage = 'login';
          },
        });
        return;
      } else {
        this.loadingLayer.close();
        this.$alert(`登录服务器失败，错误码: ${sdkErr}`, '登陆失败', {
          confirmButtonText: '确定',
        })
          .then(() => {})
          .catch(() => {});
      }
    },
    // 创建房间
    createMeet(cookie) {
      if (!this.isLogin)
        return this.$message({
          message: '当前未登录状态，请先登录！',
          type: 'warning',
        });
      // SDK接口：创建房间
      this.loadingLayer = this.$loading({
        lock: true,
        text: '正在创建房间',
      });
      // SDK接口：创建房间
      CRVideo_CreateMeeting2(cookie);
    },
    // 房间创建成功
    CreateMeetingSuccess(MeetInfoObj, cookie) {
      this.loadingLayer.close();
      this.roomData.roomID = MeetInfoObj.ID;
      this.enterMeet(MeetInfoObj.ID, 'enterBtn');
    },
    // 房间创建失败
    CreateMeetingFail(sdkErr, cookie) {
      this.loadingLayer.close();
      this.$alert(`创建房间失败，错误码: ${sdkErr}`, '创建房间', {
        confirmButtonText: '确定',
      })
        .then(() => {})
        .catch(() => {});
    },
    // 进入房间
    enterMeet(meetID, cookie) {
      if (cookie == 'enterBtn' && !this.isLogin)
        return this.$message({
          message: '当前未登录状态，请先登录！',
          type: 'warning',
        });
      if (meetID.toString().length !== 8)
        return this.$message({
          message: '房间号格式不正确！',
          type: 'warning',
        });
      const text = cookie.includes('reEnter') ? '从房间中掉线了，正常重新进入房间' : '正在进入房间';
      this.loadingLayer = this.$loading({
        lock: true,
        text: text,
      });
      // SDK接口：进入房间
      CRVideo_EnterMeeting3(meetID, cookie);
    },
    // 进入房间的结果
    EnterMeetingRslt(sdkErr, cookie) {
      this.loadingLayer.close();
      this.recordStateText = '录制';
      if (sdkErr == 0) {
        this.isMeeting = true;
        this.mainPage = 'board';
        window.localStorage.setItem('CRBoardDemo_RoomID', this.roomData.roomID);
        this.$message({
          message: '已进入房间',
          type: 'success',
          offset: 55,
        });
        this.loginData.nickname = CRVideo_GetMemberNickName(this.loginData.userID);

        this.cloudMixers = CRVideo_GetAllCloudMixerInfo();
      } else {
        this.isMeeting = false;
        this.$alert(`进入房间失败，错误码: ${sdkErr}`, '进入房间', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
        });
      }
    },
    // 从房间掉线的处理
    MeetingDropped(sdkErr) {
      this.$confirm('您已从房间中掉线，是否重新进入?', '掉线', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'error',
      })
        .then(() => {
          this.resetData();
          this.enterMeet(this.roomData.roomID, 'reEnter');
        })
        .catch(() => {
          // SDK接口：离开房间
          window.CRVideo_ExitMeeting();
          // SDK接口：退出登录
          window.CRVideo_Logout();
          this.isLogin = false;
          this.resetData();
          this.mainPage = 'login';
        });
    },
    // 房间已结束
    MeetingStopped() {
      this.$alert('房间已结束，您将回到登录界面！', '房间结束', {
        confirmButtonText: '确定',
        callback: (action) => {
          // 回到登陆界面
          // SDK接口：退出登录
          window.CRVideo_Logout();
          this.isLogin = false;
          this.resetData();
          this.mainPage = 'login';
        },
      });
    },
    // 复制房间号
    copyRoomID() {
      const input = document.querySelector('#copyInput');
      input.value = this.roomData.roomID;
      input.select();
      document.execCommand('copy');
      this.$message.success('房间号已复制');
    },
    // 点击离开房间按钮
    clickLeftBtn() {
      this.$confirm('确定要离开房间吗?', '温馨提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      })
        .then(() => {
          // SDK接口：离开房间
          window.CRVideo_ExitMeeting();
          // SDK接口：退出登录
          window.CRVideo_Logout();
          this.isLogin = false;
          this.resetData();
          this.mainPage = 'login';
        })
        .catch(() => {});
    },
    // 创建白板对应view
    createView(boardID) {
      // SDK接口：实例化一个白板view
      const boardView = new window.CRBoard_BoardView();
      // =====>>> 注意要先注册回调，再设置白板ID，否则有些回调会错过
      // SDK接口（白板view）：通知 白板view缩放比变化
      boardView.notifyScaleChanged.callback = (boardID, scale, operatorID) => {
        if (boardID == this.curBoardID) this.curView.scale = scale;
      };
      // SDK接口（白板view）：通知 白板view的可撤销状态变化
      boardView.notifyUndoEnableChanged.callback = (bool) => {
        if (boardID == this.curBoardID) this.curView.undo = bool;
      };
      // SDK接口（白板view）：通知 白板view的可恢复状态变化
      boardView.notifyRedoEnableChanged.callback = (bool) => {
        if (boardID == this.curBoardID) this.curView.redo = bool;
      };
      // SDK接口（白板view）：通知 白板view当前页改变
      boardView.notifyBoardCurPageChanged.callback = (curPageID) => {
        if (boardID == this.curBoardID) this.curView.curPage = curPageID;
      };
      // SDK接口（白板view）：通知 标注异常通知
      boardView.notifyMarkException.callback = (err) => {
        switch (err.errCode) {
          case 1:
            this.$message.warning(`当前页标注数量超过限制，无法继续标注`);
            break;
          case 2:
            this.$message.warning(`单笔标注长度超过限制，无法继续标注`);
            break;

          default:
            break;
        }
      };
      // SDK接口（白板view）：通知 用户触发了文本输入
      boardView.notifyUserTextInput.callback = (callback) => {
        this.$prompt('请输入文字内容', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
        })
          .then(({ value }) => {
            callback(value);
          })
          .catch(() => {
            this.$message({
              type: 'info',
              message: '取消输入',
            });
            callback();
          });
      };
      // SDK接口（白板view）：设置白板view的工具属性
      boardView.setToolAttr(this.defaultToolAttr);
      // SDK接口（白板view）：设置白板view每一页画布的css样式（不包括间隙）
      boardView.setCanvasStyle({
        backgroundColor: 'rgba(255,255,255,1)', // 背景透明
      });
      // SDK接口（白板view）：设置白板view中心容器dom的css样式
      boardView.setContainerStyle({
        backgroundColor: 'rgba(230,230,230,1)',
      });
      // =====>>> 注意要先注册回调，再设置白板ID，否则有些回调会错过
      // SDK接口（白板view）：设置view对应显示的白板ID和属性
      boardView.setBoardID(boardID, this.defaultAttr);
      return boardView;
    },
    // 收到通知初始化白板列表
    NotifyInitBoardList(list) {
      if (list.length == 0) return this.createBoard();
      this.boardList = list;
      this.processBoardList();
    },
    // 二次处理白板列表
    processBoardList() {
      // 白板名称
      this.boardList.forEach((item) => {
        let extInfo = JSON.parse(item.extInfo || '{}');
        item.name = extInfo.name ? extInfo.name : '';
        if (!item.view) {
          // 创建对应view
          item.view = this.createView(item.boardID);
        }
      });
    },
    // 收到通知创建了新白板
    NotifyCreateBoard(wbDesc, operatorID) {
      if (this.boardList.findIndex((item) => item.boardID == wbDesc.boardID) == -1) this.boardList.push(wbDesc);
      this.processBoardList();
    },
    // 收到通知删除了白板
    NotifyCloseBoard(boardID, operatorID) {
      const index = this.boardList.findIndex((item) => item.boardID == boardID);
      if (index != -1) {
        this.boardList.splice(index, 1);
      }
      if (this.boardList.length == 0) this.curBoardID = null;
    },
    // 收到通知变更当前白板
    NotifyCurrentBoard(boardID, operatorID) {
      if (this.boardList.length == 0) return;
      this.curBoardID = boardID == '' ? null : boardID;
    },
    // 创建白板
    createBoard() {
      if (this.boardList.length >= 10)
        return this.$message({
          message: '创建失败，同一个房间内最多只能创建10个白板',
          type: 'warning',
          offset: 55,
        });
      const width = 1280,
        height = 720,
        pageCount = 3,
        pageMode = 1;
      let boardIndex = 1,
        boardName = '';
      while (true) {
        boardName = `${this.loginData.nickname}的白板-${boardIndex++}`;
        if (this.boardList.findIndex((item) => item.name == boardName) == -1) break;
      }
      const extInfo = JSON.stringify({
        name: boardName,
      });
      // SDK接口：创建白板
      window
        .CRBoard_CreateWhiteBoard(width, height, pageCount, pageMode, extInfo)
        .then((boardInfo) => {
          this.myBoardIndex++;
          this.$message({
            message: '创建成功',
            type: 'success',
            offset: 55,
          });
          this.changeCurBoard(boardInfo.boardID);
        })
        .catch((err) => {
          console.error(err);
          return this.$message({
            message: `创建失败，${err.errDesc}`,
            type: 'warning',
            offset: 55,
          });
        });
    },
    // 点击删除白板按钮
    clickDeleteBtn() {
      if (this.boardList.length == 0) return this.$message.warning('已经没有白板啦~');

      this.$confirm('确定要删除当前白板吗?', '温馨提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      })
        .then(() => {
          const boardID = this.curBoardID;
          // SDK接口：删除白板
          window
            .CRBoard_CloseBoard(boardID)
            .then(() => {
              this.$message({
                message: '删除成功',
                type: 'success',
                offset: 55,
              });

              if (this.boardList.length == 0) {
                document.querySelector('#boardViewBox').innerHTML = '';
                this.curView.boardView = null;
              }
            })
            .catch((err) => {
              console.error(err);
              this.$message.error(`删除失败：${err}`);
            });
        })
        .catch(() => {});
    },
    // 切换当前白板
    changeCurBoard(boardID) {
      if (this.boardList.findIndex((item) => item.boardID == boardID) != -1) {
        // SDK接口：设置当前白板
        window.CRBoard_SetCurrentBoard(boardID);
      }
    },
    // 显示隐藏颜色、线宽选择容器
    toggleColorBox(boxName) {
      this.showColorBox = this.showColorBox == true ? false : true;
    },
    // 选择线宽和颜色
    choosedColorOrWidth(attr) {
      this.setCurViewToolAttr(attr);
      this.showColorBox = false;
    },
    // 设置工具属性
    setCurViewToolAttr(attr) {
      if (attr) {
        for (let key in attr) {
          this.curView.toolAttr[key] = attr[key];
        }
      }
      // SDK接口（白板view）：设置白板view的工具属性（颜色、线宽等）
      this.curView.boardView.setToolAttr(this.curView.toolAttr);
    },
    // 点击工具类型按钮
    clickToolTypeButton() {
      if ((1 <= this.curView.toolType && this.curView.toolType <= 5) || (11 <= this.curView.toolType && this.curView.toolType <= 13)) {
        this.showToolType = !this.showToolType;
      } else {
        switch (this.toolTypeButtonClass) {
          case 'pencil':
            this.setToolType(1);
            break;
          case 'straightLine':
            this.setToolType(2);
            break;
          case 'squareLine':
            this.setToolType(3);
            break;
          case 'roundLine':
            this.setToolType(4);
            break;
          case 'arrows':
            this.setToolType(5);
            break;
          case 'squareFill':
            this.setToolType(11);
            break;
          case 'roundFill':
            this.setToolType(12);
            break;
          case 'squareFill':
            this.setToolType(13);
            break;
          default:
            break;
        }
      }
      this.showColorBox = false;
      this.showFontSetBox = false;
    },
    // 选择工具类型
    chooseToolType(type) {
      this.setToolType(type);
      this.showToolType = false;
      switch (type) {
        case 1:
          this.toolTypeButtonClass = 'pencil';
          break;
        case 2:
          this.toolTypeButtonClass = 'straightLine';
          break;
        case 3:
          this.toolTypeButtonClass = 'squareLine';
          break;
        case 4:
          this.toolTypeButtonClass = 'roundLine';
          break;
        case 5:
          this.toolTypeButtonClass = 'arrows';
          break;
        case 11:
          this.toolTypeButtonClass = 'squareFill';
          break;
        case 12:
          this.toolTypeButtonClass = 'roundFill';
          break;
        case 13:
          this.toolTypeButtonClass = 'pentacleLine';
          break;

        default:
          break;
      }
    },
    // 设置工具类型
    setToolType(type) {
      this.curView.toolType = type;
      // SDK接口（白板view）：设置白板view的工具类型（画笔、矩形、箭头等）
      this.curView.boardView.setToolType(type);
      this.showToolType = false;
      // SDK接口（白板view）：设置白板view的鼠标样式
      switch (type) {
        case 1:
          this.curView.boardView.setCursor(`url(../whiteBoardDemo/imgs/鼠标光标-铅笔.cur),default`);
          break;
        case 6:
          this.curView.boardView.setCursor('text');
          break;
        case 8:
          this.curView.boardView.setCursor(`url(../whiteBoardDemo/imgs/鼠标光标-选择.cur),default`);
          break;
        case 9:
          this.curView.boardView.setCursor(`url(../whiteBoardDemo/imgs/鼠标光标-橡皮擦.cur),default`);
          break;
        case 10:
          this.curView.boardView.setCursor(`move`);
          break;
        default:
          this.curView.boardView.setCursor('default');
          break;
      }
    },
    // 点击文字按钮
    clickFontButton() {
      this.showFontSetBox = !this.showFontSetBox;
      if (this.curView.toolType != 6) {
        this.setToolType(6);
      }
    },
    // 设置文字
    setFont(type) {
      if (type == 'size') {
        //...
      }
      if (type == 'weight') {
        if (this.curView.toolAttr.fontWeight == 'bold') {
          this.curView.toolAttr.fontWeight = 'normal';
        } else {
          this.curView.toolAttr.fontWeight = 'bold';
        }
      }
      if (type == 'italic') {
        if (this.curView.toolAttr.fontStyle === 'normal') {
          this.curView.toolAttr.fontStyle = 'italic';
        } else {
          this.curView.toolAttr.fontStyle = 'normal';
        }
      }
      if (type == 'underLine') {
        if (this.curView.toolAttr.fontUnderLine === true) {
          this.curView.toolAttr.fontUnderLine = false;
        } else {
          this.curView.toolAttr.fontUnderLine = true;
        }
      }
      this.curView.boardView.setToolAttr(this.curView.toolAttr);
    },
    // 设置缩放
    setScale(action) {
      if (action == 'increase') {
        if (+this.curView.scale + 10 <= 500) {
          // SDK接口（白板view）：设置白板view的缩放比
          this.curView.boardView.setScale(+this.curView.scale + 10);
        } else {
          this.$message.warning('不能再放大了');
          this.curView.boardView.setScale(500);
        }
      } else if (action == 'decrease') {
        if (+this.curView.scale - 10 >= 100) {
          this.curView.boardView.setScale(+this.curView.scale - 10);
        } else {
          this.$message.warning('不能再缩小了');
          this.curView.boardView.setScale(100);
        }
        // 不传参（手动输入）
      } else {
        if (this.curView.scale < 100) {
          this.curView.scale = 100;
          this.$message({
            type: 'warning',
            message: '白板缩放不能小于100%',
          });
        }
        if (this.curView.scale > 500) {
          this.curView.scale = 500;
          this.$message({
            type: 'warning',
            message: '白板缩放不能大于500%',
          });
        }
        this.curView.boardView.setScale(this.curView.scale);
      }
    },
    // 撤销
    undo() {
      if (!this.curView.undo || this.curView.attr.readOnly) return;
      // SDK接口（白板view）：撤销
      this.curView.boardView.undo();
    },
    // 恢复
    redo() {
      if (!this.curView.redo || this.curView.attr.readOnly) return;
      // SDK接口（白板view）：恢复
      this.curView.boardView.redo();
    },
    // 清空
    clean() {
      if (this.curView.attr.readOnly) return;
      this.$confirm('确定要清除所有内容吗？清除后不可恢复！', '温馨提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      })
        .then(() => {
          // SDK接口（白板view）：清空
          this.curView.boardView.clearCurPage();
          // this.curView.boardView.clearAllPage();
        })
        .catch(() => {
          this.$message({
            type: 'info',
            message: '已取消',
          });
        });
    },
    // 翻页 上一页
    lastPage() {
      if (this.curView.curPage > 0) {
        this.curView.boardView.setCurPage(this.curView.curPage - 1);
      }
    },
    // 翻页 下一页
    nextpage() {
      if (this.curView.curPage < this.curView.totalPage - 1) {
        this.curView.boardView.setCurPage(this.curView.curPage + 1);
      }
    },
    // view属性设置变化
    viewAttrChange() {
      this.curView.boardView.setAttr(this.curView.attr);
    },
    // 获取当前时间
    getDate() {
      const date = new Date();
      let year = date.getFullYear(),
        month = date.getMonth() + 1,
        day = date.getDate(),
        hour = date.getHours(),
        minute = date.getMinutes(),
        second = date.getSeconds();

      month = month < 10 ? '0' + month : month;
      day = day < 10 ? '0' + day : day;
      hour = hour < 10 ? '0' + hour : hour;
      minute = minute < 10 ? '0' + minute : minute;
      second = second < 10 ? '0' + second : second;

      return {
        year,
        month,
        day,
        hour,
        minute,
        second,
      };
    },
    // 点击录制按钮
    clickRecordBtn() {
      // 未在录制中
      try {
        if (this.cloudMixers.length == 0) {
          const { year, month, day, hour, minute, second } = this.getDate();
          const CRVideo_CloudMixerCfgObj = {
            mode: 0,
            videoFileCfg: {
              svrPathName: `/${year}-${month}-${day}/${year}-${month}-${day}_${hour}-${minute}-${second}_web_WBoard_${this.roomData.roomID}.mp4`,
              vWidth: 1280,
              vHeight: 720,
              WBVer: 2,
              layoutConfig: [
                {
                  left: 0,
                  top: 0,
                  width: 1280,
                  height: 720,
                  type: 6,
                  keepAspectRatio: 1,
                  param: {
                    background: '#FFFFFFFF',
                  },
                },
              ],
            },
          };
          CRVideo_CreateCloudMixer(CRVideo_CloudMixerCfgObj);

          // 正在录制中
        } else {
          for (let index = 0; index < this.cloudMixers.length; index++) {
            CRVideo_DestroyCloudMixer(this.cloudMixers[index].ID);
          }
        }
      } catch (err) {
        console.error(err);
      }
    },
    // 云端录制状态变化
    CloudMixerStateChanged(mixerID, state, exParam, operUserID) {
      switch (state) {
        case 0:
          this.recordStateText = '录制';
          break;
        case 1:
          this.recordStateText = '启动中';
          break;
        case 2:
          this.recordStateText = '录制中';
          break;
        case 3:
          this.recordStateText = '录制出错';
          break;
        case 4:
          this.recordStateText = '正在上传';
          break;
        case 5:
          this.recordStateText = '上传完成';
          break;
        case 6:
          this.recordStateText = '上传出错';
          break;
        case 7:
          this.recordStateText = '录制';
          break;

        default:
          break;
      }

      this.cloudMixers = CRVideo_GetAllCloudMixerInfo();
    },
    // 启动云端录制状态失败
    CreateCloudMixerFailed(mixerID, sdkErr) {
      if (sdkErr == 806) {
        this.$message.error(`启动云端录制失败：没有录制权限！`);
      } else {
        this.$message.error(`启动云端录制失败：${sdkErr}`);
      }
    },
    // 录制输出状态变化
    CloudMixerOutputInfoChanged(mixerID, outputInfo) {
      if (outputInfo.state == 6) {
        this.$message.error(`云端录制文件异常：上传失败！`);
      } else if (outputInfo.state == 7) {
        this.$message.success(`云端录制成功！`);
      } else {
        // this.$message.info(`录制文件状态：${JSON.stringify(outputInfo)}`);
      }
    },
  },
});
