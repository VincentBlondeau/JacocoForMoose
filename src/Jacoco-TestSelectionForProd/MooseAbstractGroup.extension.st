Extension { #name : #MooseAbstractGroup }

{ #category : #'*Jacoco-TestSelectionForProd' }
MooseAbstractGroup >> allModelClassesAndInterfaces [
	<navigation: 'All model classes and interfaces'>
	^ MooseGroup withAll: (self allClasses reject: [ :each | each isStub ]) withDescription: 'All model classes and interfaces'
]

{ #category : #'*Jacoco-TestSelectionForProd' }
MooseAbstractGroup >> allModelClassesAndInterfacesWithDuplicatedMethods [
	<navigation: 'All model classes and interfaces with duplicated methods'>
	^ MooseGroup
		withAll:
			(self allModelClassesAndInterfaces
				select: [ :c | 
					| names |
					names := c methods collect: #signature.
					names asSet size ~= names size ])
		withDescription: 'All model classes and interfaces with duplicated methods'
]
