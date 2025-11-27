import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.black

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.lightGray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        itemAppearance.selected.iconColor = UIColor.white
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        tabBarAppearance.inlineLayoutAppearance = itemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = itemAppearance

        tabBarController.tabBar.standardAppearance = tabBarAppearance
        tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance

        if #available(iOS 13.0, *) {
            tabBarController.tabBar.unselectedItemTintColor = UIColor.lightGray
        }
        
        let homeViewController = HomeViewController()
        let homeNavController = UINavigationController(rootViewController: homeViewController)
        homeNavController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "photo.fill"), tag: 0)
        
        let searchViewController = SearchViewController()
        searchViewController.view.backgroundColor = UIColor.black
        searchViewController.title = "Search"
        let searchNavController = UINavigationController(rootViewController: searchViewController)
        searchNavController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        let favoritesViewController = FavoritesViewController()
        let favoritesNavController = UINavigationController(rootViewController: favoritesViewController)
        favoritesNavController.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart.fill"), tag: 2)
        
        let profileViewController = UIViewController()
        profileViewController.view.backgroundColor = UIColor.black
        profileViewController.title = "Profile"
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        profileNavController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 3)
        
        tabBarController.viewControllers = [homeNavController, searchNavController, favoritesNavController, profileNavController]
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}
