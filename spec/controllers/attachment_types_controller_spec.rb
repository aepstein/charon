require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AttachmentTypesController do

  def mock_attachment_type(stubs={})
    @mock_attachment_type ||= mock_model(AttachmentType, stubs)
  end

  describe "GET index" do
    it "assigns all attachment_types as @attachment_types" do
      AttachmentType.stub!(:find).with(:all).and_return([mock_attachment_type])
      get :index
      assigns[:attachment_types].should == [mock_attachment_type]
    end
  end

  describe "GET show" do
    it "assigns the requested attachment_type as @attachment_type" do
      AttachmentType.stub!(:find).with("37").and_return(mock_attachment_type)
      get :show, :id => "37"
      assigns[:attachment_type].should equal(mock_attachment_type)
    end
  end

  describe "GET new" do
    it "assigns a new attachment_type as @attachment_type" do
      AttachmentType.stub!(:new).and_return(mock_attachment_type)
      get :new
      assigns[:attachment_type].should equal(mock_attachment_type)
    end
  end

  describe "GET edit" do
    it "assigns the requested attachment_type as @attachment_type" do
      AttachmentType.stub!(:find).with("37").and_return(mock_attachment_type)
      get :edit, :id => "37"
      assigns[:attachment_type].should equal(mock_attachment_type)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created attachment_type as @attachment_type" do
        AttachmentType.stub!(:new).with({'these' => 'params'}).and_return(mock_attachment_type(:save => true))
        post :create, :attachment_type => {:these => 'params'}
        assigns[:attachment_type].should equal(mock_attachment_type)
      end

      it "redirects to the created attachment_type" do
        AttachmentType.stub!(:new).and_return(mock_attachment_type(:save => true))
        post :create, :attachment_type => {}
        response.should redirect_to(attachment_type_url(mock_attachment_type))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved attachment_type as @attachment_type" do
        AttachmentType.stub!(:new).with({'these' => 'params'}).and_return(mock_attachment_type(:save => false))
        post :create, :attachment_type => {:these => 'params'}
        assigns[:attachment_type].should equal(mock_attachment_type)
      end

      it "re-renders the 'new' template" do
        AttachmentType.stub!(:new).and_return(mock_attachment_type(:save => false))
        post :create, :attachment_type => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested attachment_type" do
        AttachmentType.should_receive(:find).with("37").and_return(mock_attachment_type)
        mock_attachment_type.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :attachment_type => {:these => 'params'}
      end

      it "assigns the requested attachment_type as @attachment_type" do
        AttachmentType.stub!(:find).and_return(mock_attachment_type(:update_attributes => true))
        put :update, :id => "1"
        assigns[:attachment_type].should equal(mock_attachment_type)
      end

      it "redirects to the attachment_type" do
        AttachmentType.stub!(:find).and_return(mock_attachment_type(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(attachment_type_url(mock_attachment_type))
      end
    end

    describe "with invalid params" do
      it "updates the requested attachment_type" do
        AttachmentType.should_receive(:find).with("37").and_return(mock_attachment_type)
        mock_attachment_type.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :attachment_type => {:these => 'params'}
      end

      it "assigns the attachment_type as @attachment_type" do
        AttachmentType.stub!(:find).and_return(mock_attachment_type(:update_attributes => false))
        put :update, :id => "1"
        assigns[:attachment_type].should equal(mock_attachment_type)
      end

      it "re-renders the 'edit' template" do
        AttachmentType.stub!(:find).and_return(mock_attachment_type(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested attachment_type" do
      AttachmentType.should_receive(:find).with("37").and_return(mock_attachment_type)
      mock_attachment_type.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the attachment_types list" do
      AttachmentType.stub!(:find).and_return(mock_attachment_type(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(attachment_types_url)
    end
  end

end
