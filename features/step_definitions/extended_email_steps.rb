Then(/^#{capture_email} subject should contain "(.*)"$/) do |email_ref, text|
  email(email_ref).subject.should =~ /#{text}/
end

Then(/^#{capture_email} subject should not contain "(.*)"$/) do |email_ref, text|
  email(email_ref).subject.should_not =~ /#{text}/
end

Then(/^#{capture_email} (text|html|parts) should( not)? contain "(.*)"$/) do |email_ref, alternative, negative, text|
  if alternative == 'parts'
    %w( text html ).each do |alt|
      Then %{#{email_ref} #{alt} should#{negative} contain "#{text}"}
    end
  else
    part = email(email_ref).send("#{alternative}_part").body
    negative.blank? ? part.should =~ /#{text}/ : part.should_not =~ /#{text}/
  end
end

Then /^#{capture_email} should(?: not)? have an attachment named "(.+)"(?: of type "(.+)")?$/ do |email_ref, negate, file, type|
  if negate.blank?
    email(email_ref).parts.attachments[file].should_not be_nil
    unless type.blank?
      email(email_ref).parts.attachments[file].content_type.should eql 'application/pdf'
    end
  else
    email(email_ref).parts.attachments[file].should be_nil
  end
end

#Then(/^#{capture_email} (text|html|parts) should not contain "(.*)"$/) do |email_ref, alternative, text|
#  email(email_ref).send("#{alternative}_part").body.should_not =~ /#{text}/
#end

