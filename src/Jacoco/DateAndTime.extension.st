Extension { #name : #DateAndTime }

{ #category : #'*Jacoco' }
DateAndTime >> asFileNameCompatibleString [

	| stream |
	stream := String new writeStream.
	self printYMDOn: stream.
	stream << '.'.
	self printHMSWithDashesOn: stream.
	^ stream contents
]

{ #category : #'*Jacoco' }
DateAndTime >> printHMSOn: aStream separatedBy: aSeparator [
	"Print just hh<aSep>mm<aSep>ss"

	self hour
		printOn: aStream
		base: 10
		length: 2
		padded: true.
	aStream nextPut: aSeparator.
	self minute
		printOn: aStream
		base: 10
		length: 2
		padded: true.
	aStream nextPut: aSeparator.
	self second
		printOn: aStream
		base: 10
		length: 2
		padded: true
]

{ #category : #'*Jacoco' }
DateAndTime >> printHMSWithDashesOn: aStream [
	"Print just hh-mm-ss"

	self printHMSOn: aStream separatedBy: $-
]
