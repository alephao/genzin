
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
      "\n\tinternal let #{@name}#{@suffix} = #{@type}().then {" +
      "\n\t\t<#Element Style#>" +
      "\n\t}"
    end

    def add_subview(view=true)
      "\t\t#{view ? 'view.' : ''}addSubview(#{@name}#{@suffix})"
    end

    def make_constraints
      "\t\t#{@name}#{@suffix}.snp.makeConstraints { make in" +
      "\n\t\t\t<#Element Constraints#>" +
      "\n\t\t}"
    end

    def bind_inputs
      if @type == UITextField
        return ["\n\t\t#{@name}#{@suffix}.rx.text.changed" +
                "\n\t\t\t.bindTo(viewModel.#{@name}#{@suffix}DidChange)" +
                "\n\t\t\t.disposed(by: disposeBag)",
                "\n\t\t#{@name}#{@suffix}.rx.controlEvent(.editingDidEndOnExit)" +
                "\n\t\t\t.bindTo(viewModel.#{@name}#{@suffix}DidReturn)" +
                "\n\t\t\t.disposed(by: disposeBag)"]
      end
      []
    end

    def bind_outputs
      if @type == UIImageView
        return ["\n\t\tviewModel.#{@name}" +
                "\n\t\t\t.drive(#{@name}#{@suffix}.rx.image)" +
                "\n\t\t\t.disposed(by: disposeBag)"]
      elsif @type == UILabel
        return ["\n\t\tviewModel.#{@name}" +
                "\n\t\t\t.drive(#{@name}#{@suffix}.rx.text)" +
                "\n\t\t\t.disposed(by: disposeBag)"]
      end
      []
    end

    def protocol_inputs
      if @type == UITextField
        return ["\tvar #{@name}|#{@suffix}DidChange: PublishSubject<String> { get }",
                "\tvar #{@name}|#{@suffix}DidReturn: PublishSubject<Void> { get }"]
      end
      []
    end

    def viewmodel_inputs_declaration
      if @type == UITextField
        return ["\tlet #{@name}#{@suffix}DidChange: PublishSubject<String> = .init()",
                "\tlet #{@name}#{@suffix}DidReturn: PublishSubject<Void> = .init()"]
      end
      []
    end

    def protocol_outputs
      if @type == UIImageView
        return ["\tvar #{@name}: Driver<UIImage> { get }"]
      elsif @type == UILabel
        return ["\tvar #{@name}: Driver<String> { get }"]
      end
      []
    end

    def viewmodel_outputs_declaration
      if @type == UIImageView
        return ["\tlet #{@name}: Driver<UIImage>"]
      elsif @type == UILabel
        return ["\tlet #{@name}: Driver<String>"]
      end
      []
    end

    def viewmodel_outputs_init
      if @type == UIImageView
        return ["\t\tself.#{@name} = Observable.just(UIImage()).asDriver(onErrorJustReturn: UIImage())"]
      elsif @type == UILabel
        return ["\t\tself.#{@name} = Observable.just(\"\").asDriver(onErrorJustReturn: \"\")"]
      end
      []
    end
  end
end