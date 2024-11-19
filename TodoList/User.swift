//
//  User.swift
//  TodoList
//
//  Created by Yelay Song on 1/3/2567 BE.
//  Copyright © 2567 BE meech-ward. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

struct User {
  let uid: String
  let email: String

  init(authData: FirebaseAuth.User) {
    uid = authData.uid
    email = authData.email ?? ""
  }

  init(uid: String, email: String) {
    self.uid = uid
    self.email = email
  }
}
