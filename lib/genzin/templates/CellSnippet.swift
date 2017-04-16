declaration:
internal let ___NAME___ = UI___TYPE___().then {
    // MARK: Outputs
    // MARK: Inputs
    ___INPUTS___
}

initialization:
addSubview(___NAME___)

constraint:
___NAME___.snp.makeConstraints { make in

}

reactor:
reactor.name
       .drive(___NAME___.rx.___REACTORPROPERTY___)
       .disposed(by: disposeBag)
