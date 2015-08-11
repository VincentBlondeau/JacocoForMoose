Extension { #name : #MooseAbstractGroup }

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> allModelMethodsCoveredByJacocoTestCases [
	^ self methodsCoveredByJacocoTestCases reject: #isStub
]

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> methodsCoveredByJacocoTestCases [
]

{ #category : #'*Jacoco-Import tests' }
MooseAbstractGroup >> selectNotIgnoredTests [
	self ifNotEmpty: [ :e | self halt] 
]

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> testsMethodsCoveringJacocoMethods [
	
]
