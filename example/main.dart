import 'package:graphql_codegen/graphql_codegen.dart';

import 'operation_visitor.dart';
import 'fetch_graphql_metadata.dart';
import 'tap.dart';

main() async {
  final typeMeta = await fetchMetadata("https://dev.lingkou.xyz/graphql");
  final visitor = OperationVisitor(typeMeta, tap: tap);
  final result = gen('''
query globalData {
  feature {
    questionTranslation
    subscription
    signUp
    discuss
    mockInterview
    contest
    store
    book
    chinaProblemDiscuss
    socialProviders
    studentFooter
    cnJobs
  }
  userStatus {
    isSignedIn
    isAdmin
    isStaff
    isSuperuser
    isTranslator
    isPremium
    isVerified
    isWechatVerified
    checkedInToday
    username
    realName
    userSlug
    groups
    jobsCompany {
      nameSlug
      logo
      description
      name
      legalName
      isVerified
      permissions {
        canInviteUsers
        canInviteAllSite
        leftInviteTimes
        maxVisibleExploredUser
      }
    }
    avatar
    optedIn
    requestRegion
    region
    activeSessionId
    permissions
    notificationStatus {
      lastModified
      numUnread
    }
    completedFeatureGuides
  }
  siteRegion
  chinaHost
  websocketUrl
}

  ''', visitor);
  print(result);
}
