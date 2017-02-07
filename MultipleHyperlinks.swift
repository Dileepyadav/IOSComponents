

override func awakeFromNib() {
        super.awakeFromNib()
        self.buildAgreeTextView(from: NSLocalizedString("I agree to the #<ts>Terms of Use# and #<pp>HIPAA#", comment: "PLEASE NOTE: please translate \"terms of service\" and \"privacy policy\" as well, and leave the #<ts># and #<pp># around your translations just as in the English version of this message."))
    }

func buildAgreeTextView(from localizedString: String) {
        
        // 1. Split the localized string on the # sign:
        let localizedStringPieces = localizedString.components(separatedBy: "#")
        // 2. Loop through all the pieces:
        let msgChunkCount = localizedStringPieces.count
        var wordLocation = CGPoint(x: CGFloat(0.0), y: CGFloat(0.0))
        for i in 0..<msgChunkCount {
            let chunk = localizedStringPieces[i]
            if (chunk == "") {
                // skip this loop if the chunk is empty
            }
            // 3. Determine what type of word this is:
            let isTermsOfServiceLink = chunk.hasPrefix("<ts>")
            let isPrivacyPolicyLink = chunk.hasPrefix("<pp>")
            let isLink = Bool(isTermsOfServiceLink || isPrivacyPolicyLink)
            // 4. Create label, styling dependent on whether it's a link:
            let label = UILabel()
            label.font = UIFont().fad_regularFont14()
            label.textColor = UIColor().fad_grayColor()
            label.numberOfLines = 2
            label.text = chunk
            label.isUserInteractionEnabled = isLink
            if isLink {
                label.textColor = UIColor().fad_primaryColor()
                label.font = UIFont().fad_semiBoldFont14()
                label.highlightedTextColor = UIColor.yellow
                // 5. Set tap gesture for this clickable text:
                let selectorAction = isTermsOfServiceLink ? #selector(self.tapOnTermsOfServiceLink) : #selector(self.tapOnPrivacyPolicyLink)
                let tapGesture = UITapGestureRecognizer(target: self, action: selectorAction)
                label.addGestureRecognizer(tapGesture)
                // Trim the markup characters from the label:
                if isTermsOfServiceLink {
                    label.text = label.text!.replacingOccurrences(of: "<ts>", with: "")
                }
                if isPrivacyPolicyLink {
                    label.text = label.text!.replacingOccurrences(of: "<pp>", with: "")
                }
            }   else {
                label.textColor = UIColor.black
            }
            // 6. Lay out the labels so it forms a complete sentence again:
            // If this word doesn't fit at end of this line, then move it to the next
            // line and make sure any leading spaces are stripped off so it aligns nicely:
            label.sizeToFit()
            if self.termsConditionView.frame.size.width < wordLocation.x + label.bounds.size.width {
                wordLocation.x = 0.0
                // move this word all the way to the left...
                wordLocation.y += label.frame.size.height
                // ...on the next line
                // And trim of any leading white space:
                label.text = label.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                label.sizeToFit()
            }
            // Set the location for this label:
            label.frame = CGRect(x: CGFloat(wordLocation.x), y: 25, width: CGFloat(label.frame.size.width), height: CGFloat(label.frame.size.height))
            // Show this label:
            self.termsConditionView.addSubview(label)
           
            // Update the horizontal position for the next word:
            wordLocation.x += label.frame.size.width
        }
        
    }
