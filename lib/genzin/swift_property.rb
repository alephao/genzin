
#!/usr/bin/env ruby

module Genzin
  class UIKitProperty
    UIImageView = 'UIImageView'
    UILabel = 'UILabel'
    UITextField = 'UITextField'

    def initialize(name, suffix, type)
      @name = name
      @suffix = suffix
      @type = type
    end

    def declaration
      return "internal let #{@name}#{@suffix} = #{@type}().then {

      }"
    end

    def add_subview(view=true)
      return "#{view ? 'view.' : ''}addSubview(#{@name}#{@suffix})"
    end

    def make_constraints
      "#{@name}#{@suffix}.snp.makeConstraints { make in

      }"
    end

    def bind_inputs
      if @type == UITextField
        return ["#{@name}#{@suffix}.rx.text.changed
                                     .bindTo(viewModel.#{@name}#{@suffix}DidChange)
                                     .disposed(by: disposeBag)",
                  "#{@name}#{@suffix}.rx.text.controlEvent(.editingDidEndOnExit)
                                     .bindTo(viewModel.#{@name}#{@suffix}DidReturn)
                                     .disposed(by: disposeBag)"]
      end
      []
    end

    def bind_outputs
      if @type == UIImageView
        return ["viewModel.#{@name}
                       .drive(#{@name}#{@suffix}.rx.image)
                       .disposed(by: disposeBag)"]
      elsif @type == UILabel
        return ["viewModel.#{@name}
                       .drive(#{@name}#{@suffix}.rx.text)
                       .disposed(by: disposeBag)"]
      end
      []
    end

    def protocol_inputs
      if @type == UITextField
        return ["var #{@name}#{@suffix}DidChange: PublishSubject<String> { get }",
                  "var #{@name}#{@suffix}DidReturn: PublishSubject<Void> { get }"]
      end
      []
    end

    def viewmodel_inputs_declaration
      if @type == UITextField
        return ["let #{@name}#{@suffix}DidChange: PublishSubject<String> = .init()",
                  "let #{@name}#{@suffix}DidReturn: PublishSubject<Void> = .init()"]
      end
      []
    end

    def protocol_outputs
      if @type == UIImageView
        return ["var #{@name}: Driver<UIImage> { get }"]
      elsif @type == UILabel
        return ["var #{@name}: Driver<String> { get }"]
      end
      []
    end

    def viewmodel_outputs_declaration
      if @type == UIImageView
        return ["let #{@name}: Driver<UIImage>"]
      elsif @type == UILabel
        return ["let #{@name}: Driver<String>"]
      end
      []
    end

    def viewmodel_outputs_init
      if @type == UIImageView
        return ["self.#{@name} = Observable.just(UIImage()).asDriver(onErrorJustReturn: UIImage())"]
      elsif @type == UILabel
        return ["self.#{@name} = Observable.just(\"\").asDriver(onErrorJustReturn: \"\")"]
      end
      []
    end
  end
end