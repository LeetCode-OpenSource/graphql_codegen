class GlobalDataQuery {
  GlobalDataFeature feature;
  GlobalDataUserStatus userStatus;
  String siteRegion;

  String chinaHost;

  String websocketUrl;
}

class GlobalDataFeature {
  bool questionTranslation;

  bool subscription;

  bool signUp;

  bool discuss;

  bool mockInterview;

  bool contest;

  bool store;

  bool book;

  bool chinaProblemDiscuss;

  String socialProviders;

  bool studentFooter;

  bool cnJobs;
}

class GlobalDataUserStatus {
  bool isSignedIn;

  bool isAdmin;

  bool isStaff;

  bool isSuperuser;

  bool isTranslator;

  bool isPremium;

  bool isVerified;

  bool isWechatVerified;

  bool checkedInToday;

  String username;

  String realName;

  String userSlug;

  List<String> groups;

  GlobalDataJobsCompany jobsCompany;
  String avatar;

  bool optedIn;

  String requestRegion;

  String region;

  num activeSessionId;

  List<String> permissions;

  GlobalDataNotificationStatus notificationStatus;
  List<String> completedFeatureGuides;
}

class GlobalDataJobsCompany {
  String nameSlug;

  String logo;

  String description;

  String name;

  String legalName;

  bool isVerified;

  GlobalDataPermissions permissions;
}

class GlobalDataPermissions {
  bool canInviteUsers;

  bool canInviteAllSite;

  num leftInviteTimes;

  num maxVisibleExploredUser;
}

class GlobalDataNotificationStatus {
  num lastModified;

  num numUnread;
}
