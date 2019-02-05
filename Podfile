source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def external_frameworks
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'RxDataSources', '~> 3.0'
    pod 'lottie-ios'
end

target 'GitHubSearch' do
    external_frameworks
end

target 'GitHubSearchTests' do    
    external_frameworks
end
