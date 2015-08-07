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
	files := self coverageXmlfolder asFileReference allFiles.
	files do: [ :file | self importFile: file. self increment ]
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
JacocoImport >> importClassXml: aXMLElement [
	| name className classCovered className2 allClasses |
	name := aXMLElement attributeAt: 'name'.
	className := name replaceAll: $/ with: $..
	className2 := '::' join: (className substrings: '.').
	allClasses := model allClasses.
	classCovered := allClasses
		entityNamed: className2
		ifAbsent: [ self logCr: '[Jacoco] Info: Class covered: ' , name , ' not Found in model.'. nil ].
	classCovered ifNotNil: [ self importMethodFromXml: aXMLElement fromContainedClass: classCovered ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> importFile: aFileReference [
	| name methodName xml methodName2  methodNameDecomposed |
	name := aFileReference basename.

	methodName := aFileReference basename copyFrom: 'void ' size +1 to: name size - 9.
	methodNameDecomposed := methodName substrings: '.'.
	methodName2 := ('::' join: methodNameDecomposed allButLast) , '.',methodNameDecomposed last.
	testMethod := model entityNamed: methodName2  .
	self assert: testMethod isNotNil.
	xml := XMLDOMParser parse: aFileReference readStream.
	self importXML: xml
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
	| name constructor description methodCovered constructorTemp methods |
	aXMLElement
		allElementsNamed: 'method'
		do: [ :aMethodXmlElement | 
			name := aMethodXmlElement attributeAt: 'name'.
			description := self parseDescription: (aMethodXmlElement attributeAt: 'desc').
			name = '<init>'
				ifTrue: [ 
					methods := aFAMIXClass methods.
					constructor := methods
						select: [ :m | m isConstructor and: [ m numberOfArgsFromSignature = (description size - 1) ] ].
					constructor
						ifEmpty: [ self logCr: '[Jacoco] Info: initializer Method ' , name , 'in Class ' , aFAMIXClass mooseName , ' not Found.' ]
						ifNotEmpty: [ 
							constructor size = 1
								ifFalse: [ 
									constructorTemp := constructor reject: #isStub.
									constructorTemp size ~= 1
										ifTrue: [ 
											self logCr: '[Jacoco] Error: Random selection in ' , constructor printString.
											constructor := {"Should resolve signature matching"
											"Should resolve signature matching"
											"Should resolve signature matching"
											"Should resolve signature matching"
											"Should resolve signature matching"
											"Should resolve signature matching"
											"Should resolve signature matching"
											"Should resolve signature matching"
											constructor first}	"Should resolve signature matching"	"Should resolve signature matching"	"Should resolve signature matching"	"Should resolve signature matching"	"Should resolve signature matching"	"Should resolve signature matching"	"Should resolve signature matching"	"Should resolve signature matching" ]
										ifFalse: [ constructor := constructorTemp ] ].
							self assert: constructor size = 1.
							constructor := constructor first.
							constructor addCoveredByJacocoTestClass: testMethod ] ]
				ifFalse: [ 
					methods := aFAMIXClass methods.
					methodCovered := methods
						select: [ :m | m name = name and: [ m numberOfArgsFromSignature = (description size - 1) ] ].
					methodCovered
						ifEmpty: [ self logCr: '[Jacoco] Info: Standard Method ' , name , 'in Class ' , aFAMIXClass mooseName , ' not Found.' ]
						ifNotEmpty: [ 
							methodCovered size = 1
								ifFalse: [ self logCr: '[Jacoco] Error: Several method found... Take random...' , methodCovered printString ].
							methodCovered := methodCovered first.
							methodCovered addCoveredByJacocoTestClass: testMethod ] ] ]
]

{ #category : #'as yet unclassified' }
JacocoImport >> importXML: aXMLDocument [
	| packageName pckName |
	aXMLDocument
		allElementsNamed: 'package'
		do: [ :aPackageXmlNode | 
			packageName := aPackageXmlNode attributeAt: 'name'.
			pckName := packageName replaceAll: $/ with: $..
			aPackageXmlNode
				allElementsNamed: 'class'
				do: [ :aClassXmlNode | self importClassXml: aClassXmlNode ] ]
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
