# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

use_frameworks!

workspace 'MultiConnectionsDummy'

def pods
  pod 'RxSwift'
  pod 'RxCocoa'
end

def testing_pods
  pod 'Quick'
  pod 'Nimble'
  pod 'Cuckoo'
  pod 'RxTest'
end

target 'MultiConnectionsDummy' do
  pods
	target 'MultiConnectionsDummyTests' do
    testing_pods
	end
end

target 'GameModule' do
	project 'GameModule/GameModule.project'
	pods
	target 'GameModuleTests' do
	 testing_pods
	end
end

target 'Shared' do
	project 'Shared/Shared.project'
end
