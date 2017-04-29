declaration:
    internal let ___NAME___ = ___TYPE___().then {

    }

initialization:
        addSubview(___NAME___)
constraint:
        ___NAME___.snp.makeConstraints { make in

        }

viewmodel:
        viewModel.name
            .drive(___NAME___.rx.___VIEWMODELPROPERTY___)
            .disposed(by: disposeBag)
