Extension { #name : #FAMIXType }

{ #category : #'*Jacoco-Infinitest' }
FAMIXType >> addInfinitestTests: aCollection [ 
	self shouldBeImplemented.
]

{ #category : #'*Jacoco-Infinitest' }
FAMIXType >> infinitestTests: aCollection [
	self privateState attributeAt: #infinitestTests put: aCollection
]

{ #category : #'*Jacoco-Infinitest' }
FAMIXType >> isConsideredAsChangedByInfinitest [
	^ self privateState attributeAt: #isConsideredAsChangedByInfinitest ifAbsentPut: [ false ]
]

{ #category : #'*Jacoco-Infinitest' }
FAMIXType >> isConsideredAsChangedByInfinitest: aBoolean [
	self privateState attributeAt: #isConsideredAsChangedByInfinitest put: aBoolean
]
