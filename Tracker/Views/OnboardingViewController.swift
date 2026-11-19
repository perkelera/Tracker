import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var pages: [UIViewController] = {
        let firstVC = UIViewController()
        let firstBackground = UIImageView()
        firstBackground.image = UIImage(named: "blue")
        firstBackground.contentMode = .scaleAspectFill
        firstBackground.clipsToBounds = true
        firstBackground.translatesAutoresizingMaskIntoConstraints = false
        firstVC.view.addSubview(firstBackground)
        
        let firstLabel = UILabel()
        firstLabel.text = "Отслеживайте только\nто, что хотите"
        firstLabel.font = .systemFont(ofSize: 32, weight: .bold)
        firstLabel.textColor = .black
        firstLabel.textAlignment = .center
        firstLabel.numberOfLines = 0
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        
        firstVC.view.addSubview(firstLabel)
        NSLayoutConstraint.activate([
            firstBackground.topAnchor.constraint(equalTo: firstVC.view.topAnchor),
            firstBackground.leadingAnchor.constraint(equalTo: firstVC.view.leadingAnchor),
            firstBackground.trailingAnchor.constraint(equalTo: firstVC.view.trailingAnchor),
            firstBackground.bottomAnchor.constraint(equalTo: firstVC.view.bottomAnchor),
            
            firstLabel.leadingAnchor.constraint(equalTo: firstVC.view.leadingAnchor, constant: 16),
            firstLabel.trailingAnchor.constraint(equalTo: firstVC.view.trailingAnchor, constant: -16),
            firstLabel.centerYAnchor.constraint(equalTo: firstVC.view.centerYAnchor, constant: 64)
        ])
        
        let secondVC = UIViewController()
        let secondBackground = UIImageView()
        secondBackground.image = UIImage(named: "red")
        secondBackground.clipsToBounds = true
        secondBackground.contentMode = .scaleAspectFill
        secondBackground.translatesAutoresizingMaskIntoConstraints = false
        secondVC.view.addSubview(secondBackground)
        
        let secondLabel = UILabel()
        secondLabel.text = "Даже если это\nне литры воды и йога"
        secondLabel.font = .systemFont(ofSize: 32, weight: .bold)
        secondLabel.textColor = .black
        secondLabel.textAlignment = .center
        secondLabel.numberOfLines = 0
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        
        secondVC.view.addSubview(secondLabel)
        NSLayoutConstraint.activate([
            secondBackground.topAnchor.constraint(equalTo: secondVC.view.topAnchor),
            secondBackground.leadingAnchor.constraint(equalTo: secondVC.view.leadingAnchor),
            secondBackground.trailingAnchor.constraint(equalTo: secondVC.view.trailingAnchor),
            secondBackground.bottomAnchor.constraint(equalTo: secondVC.view.bottomAnchor),
            
            secondLabel.leadingAnchor.constraint(equalTo: secondVC.view.leadingAnchor, constant: 16),
            secondLabel.trailingAnchor.constraint(equalTo: secondVC.view.trailingAnchor, constant: -16),
            secondLabel.centerYAnchor.constraint(equalTo: secondVC.view.centerYAnchor, constant: 64)
        ])
        return [firstVC, secondVC]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(confirmButton)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func didTapConfirmButton() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        guard let window = view.window else { return }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
