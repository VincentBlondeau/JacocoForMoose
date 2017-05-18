Extension { #name : #FAMIXMethod }

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> hasAnXMLReportFromJacoco [
	^ self privateState attributeAt: #hasAnXMLReportFromJacoco ifAbsent: [ false ]
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> hasAnXMLReportFromJacoco: aBoolean [
	self privateState attributeAt: #hasAnXMLReportFromJacoco put: aBoolean
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> isIgnored [
	<MSEProperty: #isIgnored type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment:
		'If the method is a test, it can be annotated with Ignore, the test is Bypassed'>
	^ "self privateState
		attributeAt: #isIgnored
		ifAbsentPut: [ "self isAnnotatedWith: 'Ignore' "]"
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> isMethodAnchorInTheCoreDir [
	self flag: 'SHOULD NOT BE USED FOR JACOCOStats'.
	^ self sourceAnchor
		ifNil: [ self belongsTo sourceAnchor fileName includesSubstring: 'src/main' ]
		ifNotNil: [ :sa | sa fileName includesSubstring: 'src/main' ]
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> isNotIgnoredTest [
	<MSEProperty: #isNotIgnoredTest type: #Boolean>
	<multivalued>
	<derived>
	<MSEComment: 'If the method is a not ignored test'>
	^ self privateState
		cacheAt: #isNotIgnoredTest
		ifAbsentPut: [ self isTest and: [ self isIgnored not ] ]
]

{ #category : #'*Jacoco-Import tests' }
FAMIXMethod >> isTest [
	<MSEProperty: #isTest type: #Boolean>
	<derived>
	<MSEComment: 'If the method is a test'>
	^ self isJUnit4Test or: [ self isJUnit3Test ]
]
