// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

public struct DropDownDataModel {
    public var image: String
    public var data: String
    
    public init(image: String, data: String) {
        self.image = image
        self.data = data
    }
}

public class CustomDragScrollBottomSheetVC: UIViewController {
    
    public var arrayPostOptions: [DropDownDataModel] = []
        
    public var isHeightChanged: Bool = true
    public var isFullHeight: Bool = false
    
    public let fullHeight: CGFloat = UIScreen.main.bounds.height - 120
    public let halfHeight: CGFloat = UIScreen.main.bounds.height / 2
    public let minHeight: CGFloat = 100
    
    public var isHorizontalLayout = false
    public var panGesture: UIPanGestureRecognizer!
    public var collectionViewPostOptions: UICollectionView!
    
    public var bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    
    public var dragIconView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        return view
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    private func configUI() {
                
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        bottomSheetView.frame = CGRect(x: 0, y: view.frame.maxY - halfHeight, width: view.frame.width, height: fullHeight)
        bottomSheetView.layer.shadowColor = UIColor.gray.cgColor
        bottomSheetView.layer.shadowOpacity = 1
        bottomSheetView.layer.shadowOffset = CGSize(width: 0, height: 5)
        bottomSheetView.layer.shadowRadius = 10
        bottomSheetView.layer.shadowPath = UIBezierPath(rect: bottomSheetView.bounds).cgPath
        bottomSheetView.addGestureRecognizer(panGesture)
        view.addSubview(bottomSheetView)
        
        dragIconView.frame = CGRect(x: bottomSheetView.center.x - 20, y: 10, width: 40, height: 5)
        
        configCollectionView()
        bottomSheetView.addSubview(dragIconView)

        bottomSheetView.addSubview(collectionViewPostOptions)
    }
        
    func configCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionViewPostOptions = UICollectionView(frame: CGRect(x: 0, y: 30, width: view.frame.width, height: (UIScreen.main.bounds.height / 2 - 40)), collectionViewLayout: layout)
        collectionViewPostOptions.translatesAutoresizingMaskIntoConstraints = false
        collectionViewPostOptions.showsHorizontalScrollIndicator = false
        collectionViewPostOptions.showsVerticalScrollIndicator = false
        collectionViewPostOptions.delegate = self
        collectionViewPostOptions.dataSource = self
        
        let nib = UINib(nibName: "PostOptionsCell", bundle: .module)
        collectionViewPostOptions.register(nib, forCellWithReuseIdentifier: "PostOptionsCell")
    }
    
    func toggleLayout() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = isHorizontalLayout ? .horizontal : .vertical
            collectionViewPostOptions.setCollectionViewLayout(layout, animated: false)
            
            collectionViewPostOptions.reloadData()
            if isHorizontalLayout {
                collectionViewPostOptions.frame.size.height = 50
            } else {
                collectionViewPostOptions.frame.size.height = isFullHeight ? fullHeight - 40 : (UIScreen.main.bounds.height / 2 - 30)
            }
        }
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: view)
        var newY: CGFloat = 0
        var targetY: CGFloat = 0
        
        switch recognizer.state {
        case .changed:
            // Update the position of the bottom sheet based on the gesture's translation
            if isHeightChanged {
                newY = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else {return}
                    isHeightChanged = false
                }
            } else {
                newY = bottomSheetView.frame.minY + translation.y
                newY = min(max(newY, view.frame.maxY - fullHeight), view.frame.maxY - minHeight)
            }

            if newY == 0 {
                isFullHeight = false
                targetY = view.frame.maxY - halfHeight
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else {return}
                    toggleLayout()
                    isHorizontalLayout = false
                }
            } else if newY > halfHeight {
                targetY = view.frame.maxY - minHeight
                isFullHeight = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else {return}
//                    isHeightChanged = true
                    toggleLayout()
                    isHorizontalLayout = true
                }
            } else if newY < halfHeight {
                targetY = view.frame.maxY - fullHeight
                isFullHeight = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else {return}
//                    isHeightChanged = true
                    toggleLayout()
                    isHorizontalLayout = false
                }
            }
            // Animate to the target position
            UIView.animate(withDuration: 0.3) {
                self.bottomSheetView.frame.origin.y = targetY
            }

        default:
            break
        }
    }
}

//MARK: - Collectionview delegate and data source methods -
extension CustomDragScrollBottomSheetVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayPostOptions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostOptionsCell", for: indexPath) as? PostOptionsCell
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if arrayPostOptions[indexPath.item].image == "" {
                cell?.imageIcon.image = UIImage(named: "ic_placeholder", in: .module, with: .none)
            } else {
                cell?.imageIcon.image = UIImage(named: arrayPostOptions[indexPath.item].image)
            }
            cell?.labelPostOption.text = isHorizontalLayout ? "" : arrayPostOptions[indexPath.item].data
        }
        return cell ?? UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if isHorizontalLayout {
            return CGSize(width: 75, height: collectionView.bounds.height)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return isHorizontalLayout ? 0 : 10
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

