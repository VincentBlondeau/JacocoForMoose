Class {
	#name : #JacocoImport,
	#superclass : #MooseOperator,
	#instVars : [
		'testMethod'
	],
	#category : #Jacoco
}

{ #category : #private }
JacocoImport >> basicRun [
	| files |
	Transcript clear.
	files := self coverageXmlfolder asFileReference allFiles.
	files
		do: [ :file | 
			self importFile: file.
			self increment ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> coverageXmlfolder [
	^ 'artifacts/XML_REPORTS'
]

{ #category : #accessing }
JacocoImport >> description [
	^ 'XML coverage import'
]

{ #category : #'as yet unclassified' }
JacocoImport >> findClassNamedByJacoco: name [
	"name = org/apache/log4j/helpers/PatternParser$CategoryPatternConverter"

	| nameWithDots nameWithColumns |
	nameWithDots := name replaceAll: $/ with: $..
	nameWithColumns := '::' join: (nameWithDots substrings: '.').
	^ model allClasses
		entityNamed: nameWithColumns
		ifAbsent:
			[ 
			self
				logCr:
					'[Jacoco] Info: Class covered: ' , name , ' not Found in model.'.
			NotFound signalFor: name ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> findInitializerIn: searchInCollection withClass: aClass withName: aName withDescription: description [
	| constructor selectedConstructor |
	constructor := searchInCollection select: [ :m | m isConstructor and: [ m numberOfArgsFromSignature = (description size - 1) ] ].
	constructor
		ifEmpty: [ 
			self logCr: '[Jacoco] Info: initializer Method ' , aName , 'in Class ' , aClass mooseName , ' not Found.'.
			NotFound signal ]
		ifNotEmpty: [ 
			selectedConstructor := constructor select: [ :m | m matchWithJacocoDescription: description ].
			self assert: selectedConstructor size = 1.
			^ selectedConstructor first ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> findMethodFromClass: aClass name: aName description: aDescription [
	| description methodCovered selected block |
	description := self parseDescription: aDescription.
	aName = '<init>'
		ifTrue:
			[ 
			block := [ :arg | 
			self
				findInitializerIn: arg
				withClass: aClass
				withName: aName
				withDescription: description ].
			^ [ block value: aClass methods ]
				on: AssertionFailure
				do:
					[ 
					[ block value: aClass inheritedMethods ]
						on: AssertionFailure
						do:
							[ NotFound signal	"Should be better parsed -> inheritance + Collection<Item>" ] ] ]
		ifFalse:
			[ 
			methodCovered := aClass methods
				select:
					[ :m | 
					m name = aName
						and: [ m numberOfArgsFromSignature = (description size - 1) ] ].
			methodCovered
				ifEmpty:
					[ 
					self
						logCr:
							'[Jacoco] Info: Standard Method ' , aName , 'in Class '
								, aClass mooseName , ' not Found.'.
					NotFound signalFor: aName ]
				ifNotEmpty:
					[ 
					methodCovered size = 1
						ifFalse:
							[ 
							selected := methodCovered
								select: [ :m | m matchWithJacocoDescription: description ].
							[ self assert: selected size = 1 ]
								on: AssertionFailure
								do: [ NotFound signal: aName ].
							^ selected first
							"self halt.
							self logCr: '[Jacoco] Error: Several method found... Take random...' , methodCovered printString " ].
					^ methodCovered first ] ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> importClassXml: aXMLElement [
	| name  classCovered  |
	name := aXMLElement attributeAt: 'name'.
	classCovered := self findClassNamedByJacoco: name.
	classCovered ifNotNil: [ self importMethodFromXml: aXMLElement fromContainedClass: classCovered ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> importFile: aFileReference [
	| name methodName xml methodName2 methodNameDecomposed |
	name := aFileReference basename.
	methodName := aFileReference basename copyFrom: 'void ' size + 1 to: name size - 9.
	methodNameDecomposed := methodName substrings: '.'.
	methodName2 := ('::' join: methodNameDecomposed allButLast) , '.' , methodNameDecomposed last.
	testMethod := model entityNamed: methodName2.
	self assert: testMethod isNotNil.
	[ 
	xml := JacocoSAXParser parse:  aFileReference readStream usingNamespaces: false validation: false.
	self importJacocoData: xml
	"	self importXML: xml" ]
		on: FileDoesNotExist
		do: [ self logCr: '[Jacoco]Error: file named ' , name , 'doesn''t exists!' ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> importJacocoData: aCollectionOfJacocoData [
	aCollectionOfJacocoData
		do: [ :anItem | self importJacocoItem: anItem ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> importJacocoItem: anItem [
	| aClass foundMethod |
	[ aClass := self findClassNamedByJacoco: (anItem at: 'className') ]
		on: NotFound
		do: [ ^ self ].
	[ 
	foundMethod := self
		findMethodFromClass: aClass
		name: (anItem at: 'methodName')
		description: (anItem at: 'methodSignature') ]
		on: NotFound
		do: [ ^ self ].
	foundMethod
		ifNotNil: [ foundMethod addCoveredByJacocoTestClass: testMethod ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> importMethodCoverageFile: aFileReference [
	| name methodName methodName2 xml substrings |
	name := aFileReference basename.
	methodName := aFileReference basename copyFrom: 1 to: name size - 9.
	substrings := (methodName substrings: ' ') second substrings: '.'.
	methodName2 := ('::' join: substrings allButLast) , '.' , substrings last.
	testMethod := model allModelMethods select: [ :c | c mooseName = methodName2 ].
	self assert: testMethod size = 1.
	testMethod := testMethod first.
	xml := XMLDOMParser parse: aFileReference readStream.
	self importXML: xml
]

{ #category : #'as yet unclassified' }
JacocoImport >> importMethodFromXml: aXMLElement fromContainedClass: aFAMIXClass [
	| name method |
	aXMLElement
		allElementsNamed: 'method'
		do:
			[ :aMethodXmlElement | 
			name := aMethodXmlElement attributeAt: 'name'.
			method := self findMethodFromClass: aFAMIXClass name: name description: (aMethodXmlElement attributeAt: 'desc').
			method addCoveredByJacocoTestClass: testMethod ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> importXML: aXMLDocument [
	|   |
	aXMLDocument
		allElementsNamed: 'package'
		do:
			[ :aPackageXmlNode | 
			
			aPackageXmlNode allElementsNamed: 'class' do: [ :aClassXmlNode | self importClassXml: aClassXmlNode ] ]
]

{ #category : #accessing }
JacocoImport >> length [
	^ self coverageXmlfolder asFileReference allFiles size
]

{ #category : #parsing }
JacocoImport >> parseDescription: aString [
	| cut args returnVal  |
	cut := aString substrings: ')'.
	args := cut first allButFirst substrings: ';'.
	returnVal := cut second.
	^{returnVal} , args.

]
