//
//  TodoViewController.swift
//  TodoList
//
//  Created by Sam Meech-Ward on 2020-05-14.
//  Copyright © 2020 meech-ward. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseInternal


protocol TodoViewControllerDelegate: AnyObject {
  func todoViewController(_ vc: TodoViewController, didSaveTodo todo: Todo)
}

class TodoViewController: UIViewController {
  
    let ref = Database.database().reference(withPath: "TodoList")
    
  @IBOutlet weak var textfield: UITextField!
  var todo: Todo?
  
  weak var delegate: TodoViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    textfield.text = todo?.title
  }
    
  @IBAction func save(_ sender: Any) {
      
//    let todo = Todo(title: textfield.text!)
//      let todoRef = self.ref.child(textfield.text!)
//      todoRef.setValue(todo.toAnyObject())
//    delegate?.todoViewController(self, didSaveTodo: todo)
      guard let newText = textfield.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newText.isEmpty else {
             // Handle the case when the text field is empty
             return
         }
         
         if let todo = todo {
             // Update existing todo
             updateTodo(todo, with: newText)
         } else {
             // Add new todo
             addNewTodo(with: newText)
         }
      navigationController?.popViewController(animated: true)
  }
    

    private func updateTodo(_ todo: Todo, with newText: String) {
        // Update the title of the todo
        let oldTodoRef = self.ref.child(todo.title) // Reference to the old node
        let newTodoRef = self.ref.child(newText) // Reference to the new node with updated title
        
        // Update the title of the todo object
        var updatedTodo = todo
        updatedTodo.title = newText

        // Move the existing todo to the new node
        oldTodoRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let todoData = snapshot.value as? [String: Any] else {
                // Handle the case when data doesn't exist
                return
            }
            
            // Remove the old node
            oldTodoRef.removeValue { (error, _) in
                if let error = error {
                    print("Failed to remove old todo: \(error.localizedDescription)")
                    return
                }
                
                // Set the data to the new node
                newTodoRef.setValue(todoData) { (error, _) in
                    if let error = error {
                        print("Failed to add new todo: \(error.localizedDescription)")
                        return
                    }
                    newTodoRef.child("name").setValue(newText)
                    
                    // Notify the delegate that the todo has been updated
                    self.delegate?.todoViewController(self, didSaveTodo: updatedTodo)
                }
            }
        }
    }



    private func addNewTodo(with title: String) {
        let newTodo = Todo(title: title)
        let newTodoRef = self.ref.child(title) // Reference to the new node
        
        newTodoRef.setValue(newTodo.toAnyObject()) { (error, _) in
            if let error = error {
                print("Failed to add new todo: \(error.localizedDescription)")
                return
            }
            
            // Notify the delegate that the todo has been added
            self.delegate?.todoViewController(self, didSaveTodo: newTodo)
        }
    }
  
}
