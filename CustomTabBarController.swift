//
//  CustomTabBarController.swift
//  ChatAppClients
//
//  Created by Dushko Cizaloski on 2/11/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
class CustomTabBarController: UITabBarController
{
  override func viewDidLoad()
  {
    super.viewDidLoad()
    //setup our custom view controllers
    let layout = UICollectionViewFlowLayout()
    let friendsController = ViewRecentClientsController(collectionViewLayout: layout)
    let recentMessagesController = UINavigationController(rootViewController: friendsController)
    recentMessagesController.tabBarItem.title = "Recent"
    recentMessagesController.tabBarItem.image = UIImage(named: "recent")
    createTabBarControllerViews(title: "Recent", imageName: "recent")
    viewControllers = [recentMessagesController,createTabBarControllerViews(title: "Calls", imageName: "calls"), createTabBarControllerViews(title: "People", imageName: "groups"), createTabBarControllerViews(title: "Groups", imageName: "people"), createTabBarControllerViews(title: "Settings", imageName: "settings")]
    
  }
  private func createTabBarControllerViews(title: String, imageName: String) -> UINavigationController
  {
    let viewController = UIViewController()
    let navController = UINavigationController(rootViewController: viewController)
    navController.tabBarItem.title = title
    navController.tabBarItem.image = UIImage(named:imageName)
    return navController
  }
}
