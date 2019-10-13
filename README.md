# cocoapods-force-static-framework

A description of cocoapods-force-static-framework.

## Installation

    $ gem install cocoapods-force-static-framework

## Usage
    
    plugin 'force_static_framework'
    
    force_static_framework_enable!
    
    pod 'Sample' do
        pod 'RxSwift', static => true
    end
