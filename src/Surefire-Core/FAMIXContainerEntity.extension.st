Extension { #name : #FAMIXContainerEntity }

{ #category : #'*Surefire-Core' }
FAMIXContainerEntity >> testRunningTime [
	<MSEProperty: #testRunningTime type: #Number>
	<MSEComment: 'Number of time to run this test'>
	^ self privateState attributeAt: #testRunningTime ifAbsent: [ self notExistentMetricValue ]
]

{ #category : #'*Surefire-Core' }
FAMIXContainerEntity >> testRunningTime: aNumber [
	^ self privateState attributeAt: #testRunningTime put: aNumber
]

{ #category : #'*Surefire-Core' }
FAMIXContainerEntity >> testStatus [
	<MSEProperty: #testStatus type: #Number>
	<MSEComment: 'Status after the test ran'>
	^ self privateState attributeAt: #testStatus ifAbsent: [ self notExistentMetricValue ]
]

{ #category : #'*Surefire-Core' }
FAMIXContainerEntity >> testStatus: aNumber [
	^ self privateState attributeAt: #testStatus put: aNumber
]
