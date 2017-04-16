declaration:
    internal let ___NAME___ = ___TYPE___().then {

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
