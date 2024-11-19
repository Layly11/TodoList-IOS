//
//  ViewController.swift
//  TodoList
//
//  Created by Sam Meech-Ward on 2020-05-14.
//  Copyright © 2020 meech-ward. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseInternal
import FirebaseAuth
class ViewController: UIViewController {
  
    var ref : DatabaseReference!
    var todos : [Todo] = []
    


  @IBOutlet weak var tableView: UITableView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        // อ่านข้อมูลจาก Firebase
        
        if ref == nil {
                   ref = Database.database().reference(withPath: "TodoList")
               }
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let todosData = snapshot.value as? [String: Any] else { return }
            // เติมข้อมูลลงในตัวแปร todos
            self.todos = todosData.compactMap { (key, value) in
                guard let todoData = value as? [String: Any],
                      let title = todoData["name"] as? String,
                      let isComplete = todoData["iscompleted"] as? Bool else { return nil }
                return Todo(title: title, isComplete: isComplete)
            }
            // รีโหลดข้อมูลใน TableView
            self.tableView.reloadData()
            self.navigationItem.setHidesBackButton(true, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { _, user in
          guard let user = user else { return }
          self.user = User(authData: user)
           
        }


    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard let handle = handle else { return }
        Auth.auth().removeStateDidChangeListener(handle)

    }


  @IBAction func startEditing(_ sender: Any) {
    tableView.isEditing = !tableView.isEditing
  }
    @IBAction func logout(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
        // 2
        onlineRef.removeValue { error, _ in
          // 3
          if let error = error {
            print("Removing online failed: \(error)")
            return
          }
          // 4
          do {
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
          } catch let error {
            print("Auth sign out failed: \(error)")
          }
        }
        
    }
    
  @IBSegueAction func todoViewcontroller(_ coder: NSCoder) -> TodoViewController? {
    let vc = TodoViewController(coder: coder)
    
    if let indexpath = tableView.indexPathForSelectedRow {
      let todo = todos[indexpath.row]
      vc?.todo = todo
    }
    
    vc?.delegate = self
    vc?.presentationController?.delegate = self
    
    return vc
  }
  
}

extension ViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    let action = UIContextualAction(style: .normal, title: "Complete") { action, view, complete in
      
      let todo = self.todos[indexPath.row].completeToggled()
      self.todos[indexPath.row] = todo
      
      let cell = tableView.cellForRow(at: indexPath) as! CheckTableViewCell
      cell.set(checked: todo.isComplete)
    
        cell.ref.updateChildValues([
            "completed": todo.isComplete
        ])
        tableView.reloadData()
        
      
      complete(true)
      
      print("complete")
    }
    
    return UISwipeActionsConfiguration(actions: [action])
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
}

extension ViewController: UITableViewDataSource {

  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "checked cell", for: indexPath) as! CheckTableViewCell
    
    cell.delegate = self
    
    let todo = todos[indexPath.row]
    
    cell.set(title: todo.title, checked: todo.isComplete)
    
    return cell
  }
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               // ดึง Todo ที่ต้องการลบออกมา
               let todoToDelete = todos[indexPath.row]
               
               // ลบ Todo ออกจาก Firebase
               let todoRef = self.ref.child(todoToDelete.title)
               todoRef.removeValue { (error, _) in
                   if let error = error {
                       print("Failed to delete todo: \(error.localizedDescription)")
                       return
                   }
                   
                   print("Todo deleted successfully")
                   
                   // ลบ Todo ออกจากตัวแปร todos ของ ViewController
                   self.todos.remove(at: indexPath.row)
                   
                   // ลบ Todo ออกจาก TableView
                   tableView.deleteRows(at: [indexPath], with: .automatic)
               }
           }
       }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let todo = todos.remove(at: sourceIndexPath.row)
    todos.insert(todo, at: destinationIndexPath.row)
  }
  
}

extension ViewController: CheckTableViewCellDelegate {
  
    func checkTableViewCell(_ cell: CheckTableViewCell, didChagneCheckedState checked: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let todo = todos[indexPath.row]
        let newTodo = Todo(title: todo.title, isComplete: checked)
        
        // ดึง Todo ID ของ Todo ที่เปลี่ยนแปลง
        let selectedTodoID = todo.title
        
        // อัปเดตค่า isComplete ใน Firebase
        let todoRef = self.ref.child(selectedTodoID)
        todoRef.updateChildValues(["iscompleted": checked]) { (error, ref) in
            if let error = error {
                print("Failed to update todo: \(error.localizedDescription)")
            } else {
                print("Todo updated successfully")
            }
        }
        
        // อัปเดตค่า isComplete ในตัวแปร todos ของ ViewController
        todos[indexPath.row] = newTodo
    }
  
}

extension ViewController: TodoViewControllerDelegate {
  
  func todoViewController(_ vc: TodoViewController, didSaveTodo todo: Todo) {
    
    
    
    dismiss(animated: true) {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        // update
        self.todos[indexPath.row] = todo
        self.tableView.reloadRows(at: [indexPath], with: .none)
      } else {
        // create
        self.todos.append(todo)
        self.tableView.insertRows(at: [IndexPath(row: self.todos.count-1, section: 0)], with: .automatic)
      }
    }
  
  }
  
}


extension ViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
}
