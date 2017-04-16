Gem::Specification.new do |s|
  s.name        = 'genzin'
  s.version     = '0.0.1'
  s.date        = '2017-04-16'
  s.summary     = "Genzin"
  s.description = "Swift code generator for Reactive architecture"
  s.authors     = ["Aleph Retamal, Adail Retamal, Evandro Viva"]
  s.email       = 'aleph@appzin.co'
  s.files       = spec.files = Dir.glob("*/lib/**/*", File::FNM_DOTMATCH) + Dir["bin/*"] + Dir["*/README.md"] + %w(README.md LICENSE) - Dir["*/**/.DS_Store"]
  s.homepage    =
    'https://github.com/alaphao/genzin'
  s.license       = 'MIT'
end
