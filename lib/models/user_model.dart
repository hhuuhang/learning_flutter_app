// class User {
//   final Gender? gender;
//   final String? name;
//   final String? email;

//   User({this.name, this.email, this.gender});

//   factory User.fromJson(Map<String, dynamic> json) {
//     Gender? gender;
//     switch (json['gender']) {
//       case 'male':
//         gender = Gender.male;
//         break;
//       case 'female':
//         gender = Gender.female;
//         break;
//       default:
//         gender = Gender.other;
//     }
//     return User(
//       gender: gender,
//       name: json['name'],
//       email: json['email'],
//     );
//   }
// }

// enum Gender {
//   male,
//   female,
//   other,
// }

// class Results {
//   final List<User> results;

//   Results(this.results);

//   factory Results.fromJson(Map<String, dynamic> json) {
//     final users = <User>[];

//     if (json['results'] != null) {
//       final list = json['results'] as List;
//       for (final item in list) {
//         final user = User.fromJson(item);
//         users.add(user);
//       }
//     }

//     return Results(users);
//   }
// }

class Results {
  List<User>? results;

  Results({this.results});

  Results.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <User>[];
      json['results'].forEach((v) {
        results!.add(User.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  String? gender;
  String? name;
  String? email;
  String? dob;
  String? registered;
  String? phone;
  String? status;
  Picture? picture;

  User(
      {this.gender,
      this.name,
      this.email,
      this.dob,
      this.registered,
      this.phone,
      this.status,
      this.picture});

  User.fromJson(Map<String, dynamic> json) {
    gender = json['gender'];
    name = json['name'];
    email = json['email'];
    dob = json['dob'];
    registered = json['registered'];
    phone = json['phone'];
    status = json['status'];
    picture =
        json['picture'] != null ? Picture.fromJson(json['picture']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gender'] = gender;
    data['name'] = name;
    data['email'] = email;
    data['dob'] = dob;
    data['registered'] = registered;
    data['phone'] = phone;
    data['status'] = status;
    if (picture != null) {
      data['picture'] = picture!.toJson();
    }
    return data;
  }
}

class Picture {
  String? large;
  String? medium;
  String? thumbnail;

  Picture({this.large, this.medium, this.thumbnail});

  Picture.fromJson(Map<String, dynamic> json) {
    large = json['large'];
    medium = json['medium'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['large'] = large;
    data['medium'] = medium;
    data['thumbnail'] = thumbnail;
    return data;
  }
}
