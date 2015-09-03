Extension { #name : #FAMIXBehaviouralEntity }

{ #category : #'*Surefire-Core' }
FAMIXBehaviouralEntity >> testIsGreen [
	^ self testStatus = 'pass'
]
