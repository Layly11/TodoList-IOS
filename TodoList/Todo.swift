//
//  Todo.swift
//  TodoList
//
//  Created by Sam Meech-Ward on 2020-05-14.
//  Copyright © 2020 meech-ward. All rights reserved.
//

import Foundation

struct Todo {
  var title: String
  let isComplete: Bool
  
  init(title: String, isComplete: Bool = false) {
    self.title = title
    self.isComplete = isComplete
  }
  
  func completeToggled() -> Todo {
    return Todo(title: title, isComplete: !isComplete)
  }
    
    func toAnyObject() -> Any {
      return [
        "name": title,
        "iscompleted": isComplete
      ]
    }
}
