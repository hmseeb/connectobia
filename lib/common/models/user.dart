import 'package:pocketbase/pocketbase.dart';

class Meta {
  String? expiry;
  RawUser? rawUser;
  String? id;
  String? name;
  String? username;
  String? email;
  String? avatarURL;
  String? accessToken;
  String? refreshToken;
  String? avatarUrl;

  Meta(
      {this.expiry,
      this.rawUser,
      this.id,
      this.name,
      this.username,
      this.email,
      this.avatarURL,
      this.accessToken,
      this.refreshToken,
      this.avatarUrl});

  Meta.fromJson(Map<String, dynamic> json) {
    expiry = json['expiry'];
    rawUser =
        json['rawUser'] != null ? RawUser.fromJson(json['rawUser']) : null;
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    avatarURL = json['avatarURL'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    avatarUrl = json['avatarUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['expiry'] = expiry;
    if (rawUser != null) {
      data['rawUser'] = rawUser!.toJson();
    }
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['email'] = email;
    data['avatarURL'] = avatarURL;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['avatarUrl'] = avatarUrl;
    return data;
  }
}

class RawUser {
  String? accountType;
  int? followersCount;
  int? followsCount;
  String? id;
  int? mediaCount;
  String? name;
  List<String>? permissions;
  String? profilePictureUrl;
  String? userId;
  String? username;

  RawUser(
      {this.accountType,
      this.followersCount,
      this.followsCount,
      this.id,
      this.mediaCount,
      this.name,
      this.permissions,
      this.profilePictureUrl,
      this.userId,
      this.username});

  RawUser.fromJson(Map<String, dynamic> json) {
    accountType = json['account_type'];
    followersCount = json['followers_count'];
    followsCount = json['follows_count'];
    id = json['id'];
    mediaCount = json['media_count'];
    name = json['name'];
    permissions = json['permissions'].cast<String>();
    profilePictureUrl = json['profile_picture_url'];
    userId = json['user_id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['account_type'] = accountType;
    data['followers_count'] = followersCount;
    data['follows_count'] = followsCount;
    data['id'] = id;
    data['media_count'] = mediaCount;
    data['name'] = name;
    data['permissions'] = permissions;
    data['profile_picture_url'] = profilePictureUrl;
    data['user_id'] = userId;
    data['username'] = username;
    return data;
  }
}

class Record {
  String? collectionId;
  String? collectionName;
  String? created;
  String? email;
  bool? emailVisibility;
  String? fullName;
  String? id;
  String? industry;
  bool? onboarded;
  String? profile;
  String? updated;
  String? username;
  bool? verified;

  Record(
      {this.collectionId,
      this.collectionName,
      this.created,
      this.email,
      this.emailVisibility,
      this.fullName,
      this.id,
      this.industry,
      this.onboarded,
      this.profile,
      this.updated,
      this.username,
      this.verified});

  Record.fromJson(Map<String, dynamic> json) {
    collectionId = json['collectionId'];
    collectionName = json['collectionName'];
    created = json['created'];
    email = json['email'];
    emailVisibility = json['emailVisibility'];
    fullName = json['fullName'];
    id = json['id'];
    industry = json['industry'];
    onboarded = json['onboarded'];
    profile = json['profile'];
    updated = json['updated'];
    username = json['username'];
    verified = json['verified'];
  }

  factory Record.fromRecord(RecordModel record) =>
      Record.fromJson(record.toJson());

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['collectionId'] = collectionId;
    data['collectionName'] = collectionName;
    data['created'] = created;
    data['email'] = email;
    data['emailVisibility'] = emailVisibility;
    data['fullName'] = fullName;
    data['id'] = id;
    data['industry'] = industry;
    data['onboarded'] = onboarded;
    data['profile'] = profile;
    data['updated'] = updated;
    data['username'] = username;
    data['verified'] = verified;
    return data;
  }
}

class User {
  String? token;
  Record? record;
  Meta? meta;

  User({this.token, this.record, this.meta});

  User.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    record = json['record'] != null ? Record.fromJson(json['record']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  factory User.fromRecord(RecordModel record) => User.fromJson(record.toJson());

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (record != null) {
      data['record'] = record!.toJson();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}
