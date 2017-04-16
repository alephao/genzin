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
    }
    
    // MARK: Configuring
    func configure(_ reactor: ___CELLNAME___ReactorType) {
        ___BINDREACTOR___
    }
}
