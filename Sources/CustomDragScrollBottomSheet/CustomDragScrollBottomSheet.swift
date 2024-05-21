// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

public struct BottomSheetDataModel {
    public var image: String
    public var data: String
    
    public init(image: String, data: String) {
        self.image = image
        self.data = data
    }
}

public class CustomDragScrollBottomSheetVC: UIViewController {
    
    public enum BottomSheetState {
        case full
        case half
        case minimum
    }
    
    public var arrayBottomSheetData: [BottomSheetDataModel] = []
        
    public var isHeightChanged: Bool = false
    public var isFullHeight: Bool = false
    
    public var fullHeight: CGFloat = UIScreen.main.bounds.height * 0.9 // Example height, adjust as needed
    public var halfHeight: CGFloat = UIScreen.main.bounds.height * 0.5 // Example height, adjust as needed
    public var minimumHeight: CGFloat = UIScreen.main.bounds.height * 0.1 // Example height, adjust as needed

    public var currentState: BottomSheetState = .half
    
    public var isHorizontalLayout = false
    public var transperantView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    public var bottomSheetPanGesture: UIPanGestureRecognizer!
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
        configBottomSheet()
    }
    
    public var selectedBottomSheetData: ((BottomSheetDataModel) -> Void)?
    
    func configBottomSheet() {
        
        bottomSheetPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        bottomSheetView.frame = CGRect(x: 0, y: view.frame.midY - 50, width: view.frame.width, height: fullHeight)
        bottomSheetView.backgroundColor = .white
        bottomSheetView.layer.cornerRadius = 10
        bottomSheetView.layer.shadowColor = UIColor.gray.cgColor
        bottomSheetView.layer.shadowOpacity = 1
        bottomSheetView.layer.shadowOffset = CGSize(width: 0, height: 5)
        bottomSheetView.layer.shadowRadius = 10
        bottomSheetView.layer.shadowPath = UIBezierPath(rect: bottomSheetView.bounds).cgPath
        bottomSheetView.addGestureRecognizer(bottomSheetPanGesture)
        
        transperantView.backgroundColor = .clear
        transperantView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
        view.addSubview(transperantView)
        view.addSubview(bottomSheetView)
        
        dragIconView.frame = CGRect(x: bottomSheetView.center.x - 20, y: 10, width: 40, height: 5)
        
        configCollectionView()
        bottomSheetView.addSubview(dragIconView)
        bottomSheetView.addSubview(collectionViewPostOptions)
    }

    func configCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionViewPostOptions = UICollectionView(frame: CGRect(x: 0, y: 30, width: view.frame.width, height: halfHeight), collectionViewLayout: layout)
        collectionViewPostOptions.contentInset.bottom = isHorizontalLayout ? 0 : (isFullHeight ? 0 : 20)
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
                collectionViewPostOptions.contentInset.bottom = 0
            } else {
                collectionViewPostOptions.frame.size.height = isFullHeight ? fullHeight - 40 : (UIScreen.main.bounds.height / 2 - 30)
            }
        }
    }
}

//MARK: - Gesture actions -
extension CustomDragScrollBottomSheetVC {
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        let y = bottomSheetView.frame.minY + translation.y

        switch recognizer.state {
        case .changed:
            if y >= view.frame.height - fullHeight && y <= view.frame.height - minimumHeight {
                bottomSheetView.frame.origin.y = y
                recognizer.setTranslation(.zero, in: view)
            }
        case .ended:
            let targetState: BottomSheetState
            if velocity.y > 0 {
                // Moving downward
                if currentState == .full {
                    targetState = .half
                } else {
                    targetState = .minimum
                }
                toggleLayout()
            } else {
                // Moving upward
                if currentState == .minimum {
                    targetState = .half
                } else {
                    targetState = .full
                }
                toggleLayout()
            }

            animateBottomSheet(to: targetState)
        default:
            break
        }
    }

    func animateBottomSheet(to state: BottomSheetState) {
        let targetY: CGFloat
        switch state {
        case .full:
            isHorizontalLayout = false
            isFullHeight = true
            targetY = view.frame.height - fullHeight
        case .half:
            isHorizontalLayout = false
            isFullHeight = false
            targetY = view.frame.height - halfHeight
        case .minimum:
            isHorizontalLayout = true
            targetY = view.frame.height - minimumHeight
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.bottomSheetView.frame.origin.y = targetY
        }) { _ in
            self.currentState = state
        }
    }
}

//MARK: - Collectionview delegate and data source methods -
extension CustomDragScrollBottomSheetVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayBottomSheetData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostOptionsCell", for: indexPath) as? PostOptionsCell
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if arrayBottomSheetData[indexPath.item].image == "" {
                cell?.imageIcon.image = UIImage(named: "ic_placeholder", in: .module, with: .none)
            } else {
                cell?.imageIcon.image = UIImage(named: arrayBottomSheetData[indexPath.item].image)
            }
            cell?.labelPostOption.text = isHorizontalLayout ? "" : arrayBottomSheetData[indexPath.item].data
        }
        return cell ?? UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedBottomSheetData?(arrayBottomSheetData[indexPath.item])
        self.dismiss(animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if isHorizontalLayout {
            return CGSize(width: 75, height: 70)
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
