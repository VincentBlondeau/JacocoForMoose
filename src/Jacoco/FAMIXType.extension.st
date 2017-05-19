Extension { #name : #FAMIXType }

{ #category : #'*Jacoco' }
FAMIXType >> innerClasses [
	^( self methods flatCollect: [:m |(m classes collect: #innerClasses) addAll:  m classes ] )
]

{ #category : #'*Jacoco' }
FAMIXType >> innerMethods [
	^ self innerClasses flatCollect: #methods
]

{ #category : #'*Jacoco' }
FAMIXType >> isJUnit3TestCaseWhenYouDoNotHaveAllTheInformations [
	^ (((self name beginsWith: 'Test') or: [ self name endsWith: 'Test' ])
		and: [ self sourceAnchor ifNotNil: [ :sa | sa fileName includesSubstring: 'src/test/java' ] ifNil: [ true ] ])
		and: [ self methods anySatisfy: [ :m | m name beginsWith: 'test' ] ]
]

{ #category : #'*Jacoco' }
FAMIXType >> isTestCase [
	<MSEProperty: #isTestCase type: #Boolean>
	<derived>
	<MSEComment: 'True if the method is considered as a Java test'>
	^ self isJUnit3TestCaseWhenYouDoNotHaveAllTheInformations
		or: [ self isJUnit3TestCase or: [ self isJUnit4TestCase ] ]
]

{ #category : #'*Jacoco' }
FAMIXType >> jacocoChildren [
	^ self classes , (self classes flatCollect: #jacocoChildren)
		, self methods
]

{ #category : #'*Jacoco-Import temp to migrate to moose' }
FAMIXType >> methodsUnderstanding: signature [
	"returns true if a class is able to respond to an invocation to aSignature on itself; false otherwise"

	| return |
	return := OrderedCollection new.
	self
		withSuperclassesDo: [ :each | return add: (each implementationOf: signature) ].
	^ return select: #isNotNil
]
