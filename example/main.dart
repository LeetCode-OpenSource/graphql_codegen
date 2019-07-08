import 'dart:io';
import 'package:graphql_codegen/graphql_codegen.dart';

import 'operation_visitor.dart';
import 'fetch_graphql_metadata.dart';
import 'tap.dart';

main() async {
  final typeMeta = await fetchMetadata("https://dev.lingkou.work/graphql?");
  final globalResult = gen('''
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

  ''', OperationVisitor(typeMeta, tap: tap));
  final globalFile = File.fromUri(Uri.file('./global.dart'));
  await globalFile.writeAsString(globalResult);
  final questionResult = gen('''
  query questionNode(\$titleSlug: String) {
    question(titleSlug: \$titleSlug) {
      questionId
      questionTitle
      translatedTitle
      translatedContent
      content
      difficulty
      stats
      status
    }
  }

  ''', OperationVisitor(typeMeta, tap: tap));
  final questionFile = File.fromUri(Uri.file('./question.dart'));
  await questionFile.writeAsString(questionResult);
}
