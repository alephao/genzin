import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class ___CONTROLLERNAME___ViewController: BaseViewController {
    
    // MARK: - UI Elements
___PROPERTIES___
    
    // MARK: Overrided
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Initializing
    init(viewModel: ___CONTROLLERNAME___ViewModelType) {
        super.init()
        self.configure(viewModel)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func setupConstraints() {
___CONSTRAINTS___
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hex(0xffffff)
        
___ADDSUBVIEW___
    }
    
    // MARK: - Configuring
    private func configure(_ viewModel: ___CONTROLLERNAME___ViewModelType) {
        // MARK: ViewModel Inputs
___BINDVIEWMODELINPUTS___
        
        // MARK: ViewModel Outputs
___BINDVIEWMODELOUTPUTS___

    }
}

