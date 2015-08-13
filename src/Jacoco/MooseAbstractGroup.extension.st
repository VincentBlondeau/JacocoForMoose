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
	^ self select: [:m | m isNotIgnoredTest ] 
]

{ #category : #'*Jacoco-Import' }
MooseAbstractGroup >> testsMethodsCoveringJacocoMethods [
	
]
