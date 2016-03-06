Extension { #name : #Collection }

{ #category : #'*Jacoco' }
Collection >> randomSelect: aNumber [
	^ (1 to: aNumber) collect: [ :number | self atRandom ]
]
