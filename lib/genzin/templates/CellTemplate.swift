import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class ___CELLNAME___: BaseTableViewCell {

    internal let disposeBag = DisposeBag()

    // MARK: Properties
___PROPERTIES___

    // MARK: Initializing
    override func initialize() {
___ADDSUBVIEW___

___CONSTRAINTS___
    }

    // MARK: Configuring
    func configure(_ viewModel: ___CELLNAME___ViewModelType) {
        // MARK: ViewModel Inputs

___BINDVIEWMODELINPUTS___

        // MARK: ViewModel Outputs

___BINDVIEWMODELOUTPUTS___
    }
}
