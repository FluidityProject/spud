/*  Copyright (C) 2006 Imperial College London and others.
    
    Please see the AUTHORS file in the main source directory for a full list
    of copyright holders.

    Prof. C Pain
    Applied Modelling and Computation Group
    Department of Earth Science and Engineering
    Imperial College London

    C.Pain@Imperial.ac.uk
    
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation,
    version 2.1 of the License.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
    USA
*/
#include "FLOption.h"

// FLOption CLASS METHODS

// PUBLIC METHODS

using namespace std;

/**
 * Construct a non-verbose non-attribute empty element with no defined path or name.
 */
FLOption::FLOption(){
  verbose_off();
  set_rank_and_shape(-1, NULL);
  is_attribute = false;
}

/**
 * Construct a new element as a copy of the supplied element.
 */
FLOption::FLOption(const FLOption& in){
  *this = in;
}

/**
 * Construct a non-verbose non-attribute empty element with the given option path and name.
 */
FLOption::FLOption(std::string path, std::string name){
  verbose_off();
  node_path = path;
  node_name = name;
  set_rank_and_shape(-1, NULL);
  is_attribute = false;
}

/**
 * Destructor.
 */
FLOption::~FLOption(){
}

/**
 * Make this element a copy of the supplied element.
 */
const FLOption& FLOption::operator=(const FLOption& in){
  verbose = in.verbose;
  
  if(verbose)
    cout<<"const FLOption& FLOption::operator=(const FLOption& in)\n";
  
  node_path = in.node_path;
  node_name = in.node_name;
  children = in.children;

  data_bool = in.data_bool;
  data_double = in.data_double;
  data_int = in.data_int;
  data_string = in.data_string;
  set_rank_and_shape(in.rank, in.shape);
  
  is_attribute = in.is_attribute;

  return *this;
}

/**
 * Get the name of this element.
 */
std::string FLOption::get_name() const{
  return node_name;
}

/**
 * Get the option path for this element.
 */
std::string FLOption::get_path() const{
  return node_path;
}

/**
 * Get the attribute status for this element.
 */
logical_t FLOption::get_is_attribute() const{
  return is_attribute;
}

/** 
 * Attempt to set the attribute status for this element. Only elements with string data and no children may be marked as attributes.
 */
logical_t FLOption::set_is_attribute(logical_t is_attribute){
  if(children.size() == 0 and get_option_type() == OPTION_TYPE_STRING){
    this->is_attribute = is_attribute;
  }
  
  return this->is_attribute;
}

/** 
 * Get the child of this element at the supplied option path (const version).
 */
const FLOption* FLOption::get_child(string str) const{
  if(verbose)
    cout << "const FLOption* FLOption::get_child("<<str<<") const\n";

  if(str == "/" or str.empty())
    return this;

  string name, branch;
  int index;
  split_name(str, name, index, branch);

  if(name.empty()){
    cerr << "ERROR: child name cannot be empty\n";
    exit(-1);
  }

  multimap<string, FLOption>::const_iterator it;
  if(children.count(name) == 0){
    name += "::";
    int i = 0;
    for(it = children.begin();it != children.end();it++){
      if(it->first.compare(0, name.size(), name) == 0){
        if(index < 0 or i == index){
          break;
        }else{
          i++;
        }
      }
    }
  }else{
    if(index < 0){
      it = children.find(name);
    }else{
      std::pair<std::multimap< std::string, FLOption>::const_iterator, std::multimap<std::string, FLOption>::const_iterator> range = children.equal_range(name);
      it = range.first;
      for(int i = 0;it != range.second;it++, i++){
        if(i == index){
          break;
        }
      }
    }
  }

  if(it == children.end()){
    return NULL;
  }else if(branch.empty()){    
    return &(it->second);
  }else{
    return it->second.get_child(branch);
  }
}

/**
 * Get the child of this element at the supplied option path (non-const version - checks that the child exists, and if it does finds it with create_child).
 */
FLOption* FLOption::get_child(string str){
  if(verbose)
    cout << "FLOption* FLOption::get_child("<< str <<")\n";
    
  if(!have_option(str)){
    return NULL;
  }else{
    return create_child(str);
  }
}

/** 
 * Get the data from this element or, if this element hold array data, get the first element of the array. Tranparently seeks into __value sub-element if this exists.
 */
const void *FLOption::get_option() const{

  if(have_option("__value")){
    return children.find("__value")->second.get_option();
  }

  switch(get_option_type()){
    case(OPTION_TYPE_DOUBLE):
      return &(data_double[0]);
    case(OPTION_TYPE_INT):
      return &(data_int[0]);
    case(OPTION_TYPE_BOOL):
      return &(data_bool[0]);
    case(OPTION_TYPE_NULL):
      break;
    case(OPTION_TYPE_STRING):
      return data_string.c_str();
    default:
      cerr << "ERROR: Invalid option type\n";
      exit(-1);
  }
  
  return NULL;
}

/** 
 * Get the logical data from this element. Tranparently seeks into __value sub-element if this exists.
 */
int FLOption::get_option(std::vector<logical_t>& data) const{
  if(verbose)
    cout<<"const void* FLOption::get_option(std::vector<logical_t>&) const\n";

  if(have_option("__value")){
    return get_option("__value", data);
  }else if(get_option_type() == OPTION_TYPE_BOOL){
    data = data_bool;
    return 0;
  }

  return -1;
}

/** 
 * Get the double data from this element. Tranparently seeks into __value sub-element if this exists.
 */
int FLOption::get_option(std::vector<double>& data) const{
  if(verbose)
    cout<<"const void* FLOption::get_option(std::vector<double>&) const\n";

  if(have_option("__value")){
    return get_option("__value", data);
  }else if(get_option_type() == OPTION_TYPE_DOUBLE){
    data = data_double;
    return 0;
  }

  return -1;
}

/** 
 * Get the integer data from this element. Tranparently seeks into __value sub-element if this exists.
 */
int FLOption::get_option(std::vector<int>& data) const{
  if(verbose)
    cout<<"const void* FLOption::get_option(std::vector<int>&) const\n";

  if(have_option("__value")){
    return get_option("__value", data);
  }else if(get_option_type() == OPTION_TYPE_INT){
    data = data_int;
    return 0;
  }

  return -1;  
}

/** 
 * Get the string data from this element. Tranparently seeks into __value sub-element if this exists.
 */
int FLOption::get_option(std::string& data) const{
  if(verbose)
    cout<<"const void* FLOption::get_option(std::string&) const\n";

  if(have_option("__value")){
    return get_option("__value", data);
  }else if(get_option_type() == OPTION_TYPE_STRING){
    data = data_string;
    return 0;
  }

  return -1;
}

/** 
 * Get the logical data from the supplied option path.
 */
int FLOption::get_option(std::string str, std::vector<logical_t>& data) const{
  if(have_option(str)){
    return get_child(str)->get_option(data);
  }else{
    return -1;
  }
}

/** 
 * Get the double data from the supplied option path.
 */
int FLOption::get_option(std::string str, std::vector<double>& data) const{
  const FLOption* child = get_child(str);
  if(child == NULL){
    return -1;
  }else{
    return child->get_option(data);
  }
}

/** 
 * Get the integer data from the supplied option path.
 */
int FLOption::get_option(std::string str, std::vector<int>& data) const{
  const FLOption* child = get_child(str);
  if(child == NULL){
    return -1;
  }else{
    return child->get_option(data);
  }
}

/**
 * Get the string data from the supplied option path.
 */
int FLOption::get_option(std::string str, std::string& data) const{
  const FLOption* child = get_child(str);
  if(child == NULL){
    return -1;
  }else{
    return child->get_option(data);
  }
}

/** 
 * Get the number of elements at the supplied option path. Searches un-named elements first, and if this is zero searches (from this highest element in the tree first) named elements.
 */
int FLOption::get_option_count(std::string str) const{
  if(verbose)
    cout<<"int FLOption::get_option_count("<<str<<") const\n";
  
  string name, branch;
  int index;
  split_name(str, name, index, branch);

  if(name.empty()){
    return 0;
  }
  
  if(!children.count(name)){
    // Apparently there is no such child but lets check for "name::*"
    name = name+"::";
  }

  int count=0, i=0;
  for(multimap<string, FLOption>::const_iterator it=children.begin();it!=children.end(); it++){
    if(it->first.compare(0, name.size(), name)==0){
      if(index<0){
        if(branch.empty())
          count++;
        else{
          count+=it->second.get_option_count(branch);
        }
      }else{
        if(i==index){
          if(branch.empty())
            count++;
          else
            count+=it->second.get_option_count(branch);
          break;
        }
        i++;
      }
    }
  }
  
  return count;
}

/**
 * Get the rank of the data in this element.
 */
size_t FLOption::get_option_rank() const{
  if(have_option("__value")){
    return children.find("__value")->second.get_option_rank();
  }else{
    return rank;
  }
}

/**
 * Get the shape of the data in this element.
 */
void FLOption::get_option_shape(int *shape) const{
  if(have_option("__value")){
    children.find("__value")->second.get_option_shape(shape);
    return;
  }else{  
    shape[0] = this->shape[0];
    shape[1] = this->shape[1];
  }
}

/**
 * Get the size of the data in this element. For array data this is the same as the rank. For string data this is the length of the string.
 */
size_t FLOption::get_option_size() const{
  if(verbose)
    cout<<"size_t FLOption::get_option_size() const\n";
  
  if(have_option("__value")){
    return children.find("__value")->second.get_option_size();
  }
  
  switch(get_option_type()){
    case(OPTION_TYPE_DOUBLE):
      return data_double.size();
    case(OPTION_TYPE_INT):
      return data_int.size();
    case(OPTION_TYPE_BOOL):
      return data_bool.size();
    case(OPTION_TYPE_NULL):
      break;
    case(OPTION_TYPE_STRING):
      return data_string.size();
    default:
      cerr << "ERROR: Invalid option type\n";
      exit(-1);
  }
  
  return 0;
}

/**
 * Get the type of the data in this element.
 */
FLOptionType FLOption::get_option_type() const{
  if(verbose)
    cout<<"FLOptionType FLOption::get_option_type() const\n";

  if(have_option("__value")){
    return children.find("__value")->second.get_option_type();
  }

  if(!data_bool.empty()){
    return OPTION_TYPE_BOOL;
  }else if(!data_double.empty()){
    return OPTION_TYPE_DOUBLE;
  }else if(!data_int.empty()){
    return OPTION_TYPE_INT;
  }else if(!data_string.empty()){
    return OPTION_TYPE_STRING;
  }else{
    return OPTION_TYPE_NULL;
  }
}

/**
 * Test if an element exists at the supplied option path.
 */
logical_t FLOption::have_option(string str) const{
  if(verbose)
    cout<<"bool FLOption::have_option(\""<<str<<"\") const\n";

  if(str=="/")
    return true;

  return (get_child(str) != NULL);
}

/**
 * Generate a list containing the names of the children of this element.
 */
void FLOption::list_children(string name, deque<string>& kids) const{
  if(verbose)
    cout<<"void list_children(string name, deque<string>& kids) const\n";
  
  kids.clear();

  const FLOption* descendant = get_child(name);
  if(descendant != NULL){
    for(map<string, FLOption>::const_iterator it=descendant->children.begin(); it!=descendant->children.end(); it++){
      kids.push_back(it->first);
    }
  }
  
  return;
}

/**
 * Read from an XML file with the given filename. Sets the name of this element to be that of the root element in the supplied XML file, and adds children to this element corresponding the the data in the XML file.
 */
void FLOption::load_options_xml(string xmlfile){
  if(verbose)
    cout<<"void FLOption::load_options_xml("<<xmlfile<<")\n";

  TiXmlDocument doc(xmlfile);
  doc.SetCondenseWhiteSpace(false);
  if(!doc.LoadFile()){
    cerr<<"WARNING: Failed to load options file. This may prove fatal.\n";
    return;
  }
  
  TiXmlNode *header = doc.FirstChild();
  TiXmlNode *fluidity_options = header->NextSibling();

  // Set the name of this element
  node_name = fluidity_options->ValueStr();

  // Decend down through all the fluidity options
  TiXmlNode *option_node=0;
  
  for(option_node=fluidity_options->FirstChild(); option_node; option_node=option_node->NextSibling()){
    if(option_node->ToElement()){
      parse_node("", option_node);
    }
  }

  return;
}

/**  Write out this element and all of its children to an XML file with the supplied filename.
  */
void FLOption::write_options_xml(string xmlfile) const{
  if(verbose)
    cout << "void FLOption::write_options_xml(" << xmlfile << ")\n";
    
  TiXmlDocument doc;
  
  // XML header
  TiXmlDeclaration* header = new TiXmlDeclaration("1.0", "", "");
  doc.LinkEndChild(header);

  // Root node
  TiXmlNode* root_node = to_element();
  doc.LinkEndChild(root_node);

  if(!doc.SaveFile(xmlfile)){
    cerr << "WARNING: Failed to write options file.\n";
  }

  return;
}

/**  Parses the supplied TiXmlNode and sets the data and and attribute status of this element appropriately.
  */
void FLOption::parse_node(string root, const TiXmlNode *node){
  if(verbose)
    cout<<"void FLOption::parse_option(\""<<root<<"\", const TiXmlNode *node)\n"; 
  
  // In fact I think at this level I only ever deal with ELEMENT -
  // time will tell
  if(node->Type()!=TiXmlNode::ELEMENT){
    cerr<<"WARNING - non-element: "<<root<<endl;
    return;
  }

  const TiXmlElement *element = node->ToElement();
  
  // Establish new base name of this node
  string basename = root+"/"+node->ValueStr();
  if(element->Attribute("name")){
    basename = basename+"::"+element->Attribute("name");
  }

  // Ensure this path has been added
  FLOption* child = create_child(basename);
  if(child == NULL){
    cerr << "ERROR: Unexpected failure when creating child element\n";
    exit(-1);
  }

  // Store node attributes
  for(const TiXmlAttribute *att=element->FirstAttribute(); att; att=att->Next()){
    string att_name(basename+"/"+att->Name());
    set_attribute(att_name, att->ValueStr());
  }

  // Loop through all child elements
  for(const TiXmlNode *cnode=node->FirstChild(); cnode; cnode=cnode->NextSibling()){
    switch(cnode->Type()){
      case(TiXmlNode::ELEMENT):
        break;
      case(TiXmlNode::TEXT):
        // Store node data
        set_option(basename, cnode->ValueStr());
        continue;
      default:
        continue;
    }

    // Special case when the child of cnode is empty
    if(!cnode->FirstChild()){
      parse_node(basename, cnode);
      continue;
    }
    
    const TiXmlElement *celement = cnode->ToElement();      
        
    if(cnode->ValueStr()==string("integer_value")){
      // Tokenise the data stored and convert to integers
      vector<string> tokens;
      Tokenize(cnode->FirstChild()->ValueStr(), tokens);
      
      // Find shape and rank
      int rank, shape[2];
      istringstream(celement->Attribute("rank"))>>rank;
      if(rank==1){
        // istringstream(celement->Attribute("shape"))>>shape[0];
        shape[0] = tokens.size();
      }else if(rank==2){
        istringstream(celement->Attribute("shape"))>>shape[0]>>shape[1];
      }
      
      vector<int> val;
      val.resize(tokens.size());
      for(size_t i=0;i<tokens.size();i++)
        istringstream(tokens[i])>>val[i];
      
      set_option(basename+"/__value", rank, shape, val);
      for(const TiXmlAttribute *att=celement->FirstAttribute(); att; att=att->Next()){
        string att_name(basename+"/__value/"+att->Name());
        set_attribute(att_name, att->ValueStr());
      }
    }else if(cnode->ValueStr()==string("logical_value")){
      // Tokenise the data stored and convert to integers
      vector<string> tokens;
      Tokenize(cnode->FirstChild()->ValueStr(), tokens);

      // Find shape and rank
      int rank, shape[2];
      istringstream(celement->Attribute("rank"))>>rank;
      if(rank==1){
        shape[0] = tokens.size();
      }else if(rank==2){
        istringstream(celement->Attribute("shape"))>>shape[0]>>shape[1];
      }
            
      vector<logical_t> val;
      val.resize(tokens.size());
      for(size_t i=0;i<tokens.size();i++){
        if(tokens[i]=="false")
          val[i] = 0;
        else
          val[i] = 1;
      }
      
      set_option(basename+"/__value", rank, shape, val);
      for(const TiXmlAttribute *att=celement->FirstAttribute(); att; att=att->Next()){
        string att_name(basename+"/__value/"+att->Name());
        set_attribute(att_name, att->ValueStr());
      }
    }else if(cnode->ValueStr()==string("real_value")){
      // Tokenise the data stored and convert to integers
      vector<string> tokens;
      Tokenize(cnode->FirstChild()->ValueStr(), tokens);
      
      // Find shape and rank
      int rank, shape[2];
      istringstream(celement->Attribute("rank"))>>rank;
      if(rank==1){
        shape[0] = tokens.size();
      }else if(rank==2){
        istringstream(celement->Attribute("shape"))>>shape[0]>>shape[1];
      }
            
      vector<double> val;
      val.resize(tokens.size());
      for(size_t i=0;i<tokens.size();i++)
        istringstream(tokens[i])>>val[i];
            
      set_option(basename+"/__value", rank, shape, val);
      for(const TiXmlAttribute *att=celement->FirstAttribute(); att; att=att->Next()){
        string att_name(basename+"/__value/"+att->Name());
        set_attribute(att_name, att->ValueStr());
      }
    }else if(cnode->ValueStr()==string("string_value")){
      set_option(basename+"/__value", cnode->FirstChild()->ValueStr());
      for(const TiXmlAttribute *att=celement->FirstAttribute(); att; att=att->Next()){
        string att_name(basename+"/__value/"+att->Name());
        set_attribute(att_name, att->ValueStr());
      }
    }else{
      parse_node(basename, cnode);
    }
  }
}

/**  Convert this element into a TiXmlElement.
  */
TiXmlElement* FLOption::to_element() const{
  if(verbose){
    cout << "TiXmlElement* to_element(void) const\n";
  }

  // Create new element
  TiXmlElement* ele = new TiXmlElement(node_name);

  // Set element name and name attribute if composite name
  string node_name, name_attr;
  split_node_name(node_name, name_attr);
  if(name_attr.size() > 0){
    ele->SetValue(node_name);
    ele->SetAttribute("name", name_attr);
  }
  
  // Set data
  TiXmlText* data_ele = new TiXmlText("");
  data_ele->SetValue(data_as_string());
  ele->LinkEndChild(data_ele);
  
  for(map<string, FLOption>::const_iterator iter = children.begin();iter != children.end();iter++){
    if(iter->second.is_attribute){
      // Add attribute
      ele->SetAttribute(iter->second.node_name, iter->second.data_as_string());
    }else{
      TiXmlElement* child_ele = iter->second.to_element();
      if(iter->second.node_name == "__value"){
        // Detect data sub-element
        switch(iter->second.get_option_type()){
          case(OPTION_TYPE_DOUBLE):
            child_ele->SetValue("real_value");
            break;
          case(OPTION_TYPE_INT):
            child_ele->SetValue("integer_value");
            break;
          case(OPTION_TYPE_BOOL):
            child_ele->SetValue("logical_value");
            break;
          case(OPTION_TYPE_NULL):
            break;
          case(OPTION_TYPE_STRING):
            child_ele->SetValue("string_value");
            break;
          default:
            cerr << "ERROR: Invalid option type\n";
            exit(-1);
         }
      }
      // Add child
      ele->LinkEndChild(child_ele);
    }
  }
  return ele;
}

/**  Print this element to standard output.
  */
void FLOption::print() const{
  string::size_type last_pos=0;
  string space("");
  while((last_pos = node_path.find_first_of("/", last_pos))!=string::npos){
    space+=" ";
    last_pos++;
  }
  cout<<space<<node_name;
  space+=" ";
  
  if(children.empty()){
    cout<<": ";
    if(!data_bool.empty())
      for(vector<logical_t>::const_iterator i=data_bool.begin();i!=data_bool.end();++i){
        if(*i)
          cout<<"false ";
        else
          cout<<"true ";
      }
    else if(!data_double.empty())
      for(vector<double>::const_iterator i=data_double.begin();i!=data_double.end();++i)
        cout<<*i<<" ";
    else if(!data_int.empty())
      for(vector<int>::const_iterator i=data_int.begin();i!=data_int.end();++i)
        cout<<*i<<" ";
    else if(!data_string.empty())
      cout<<data_string;
    else
      cout<<"NULL";
    cout<<endl;
  }else{
    cout<<"/"<<endl;
    
    if(!data_bool.empty()){
      cout<<space<<"<value>: ";
      for(vector<logical_t>::const_iterator i=data_bool.begin();i!=data_bool.end();++i){
        if(*i)
          cout<<"false ";
        else
          cout<<"true ";
      }
    }else if(!data_double.empty()){
      cout<<space<<"<value>: ";
      for(vector<double>::const_iterator i=data_double.begin();i!=data_double.end();++i)
        cout<<*i<<" ";
      cout<<endl;
    }else if(!data_int.empty()){
      cout<<space<<"<value>: ";
      for(vector<int>::const_iterator i=data_int.begin();i!=data_int.end();++i)
        cout<<*i<<" ";
      cout<<endl;
    }else if(!data_string.empty()){
      cout<<space<<"<value>: "<<data_string;
      cout<<endl;
    }
    for(std::map<std::string, FLOption>::const_iterator i=children.begin(); i!=children.end(); ++i)
      i->second.print();
  }
  return;
}

/**  Find or add a new element at the supplied option path.
  */
int FLOption::add_option(std::string str){
  return create_child(str) == NULL ? 1 : 0;
}

/**  Set the data in the element with the supplied logical data. Transparently sets the data of a __value sub-element if this exists.
  */
int FLOption::set_option(int rank, const int *shape, std::vector<logical_t>& data){
  if(have_option("__value")){
    return set_option("__value", rank, shape, data);
  }else{  
    data_bool = data;
    set_option_type(OPTION_TYPE_BOOL);
    set_rank_and_shape(rank, shape);
    return 0;
  }
}

/**  Set the data at the supplied option path with the supplied logical data.
  */
int FLOption::set_option(std::string str, int rank, const int *shape, std::vector<logical_t>& data){
  FLOption* opt = create_child(str);
  
  if(opt == NULL){
    return -1;
  }else{
    return opt->set_option(rank, shape, data);
  }
}

/**  Set the data in the element with the supplied double data. Transparently sets the data of a __value sub-element if this exists.
  */
int FLOption::set_option(int rank, const int *shape, std::vector<double>& data){
  if(have_option("__value")){
    return set_option("__value", rank, shape, data);
  }else{  
    data_double = data;
    set_option_type(OPTION_TYPE_DOUBLE);
    set_rank_and_shape(rank, shape);
    return 0;
  }
}

/**  Set the data at the supplied option path with the supplied double data.
  */
int FLOption::set_option(std::string str, int rank, const int *shape, std::vector<double>& data){
  FLOption* opt = create_child(str);
    
  if(opt == NULL){
    return -1;
  }else{
    return opt->set_option(rank, shape, data);
  }
}

/**  Set the data in the element with the supplied integer data. Transparently sets the data of a __value sub-element if this exists.
  */
int FLOption::set_option(int rank, const int *shape, std::vector<int>& data){
  if(have_option("__value")){
    return set_option("__value", rank, shape, data);
  }else{  
    data_int = data;
    set_option_type(OPTION_TYPE_INT);
    set_rank_and_shape(rank, shape);
    return 0;
  }
}

/**  Set the data at the supplied option path with the supplied integer data.
  */
int FLOption::set_option(std::string str, int rank, const int *shape, std::vector<int>& data){
  FLOption* opt = create_child(str);
  
  if(opt == NULL){
    return -1;
  }else{
    return opt->set_option(rank, shape, data);
  }
}

/**  Set the data in the element with the supplied string data. Transparently sets the data of a __value sub-element if this exists.
  */
int FLOption::set_option(std::string data){
  if(verbose)
    cout<<"void FLOption::set_option("<<data<<")\n";

  if(have_option("__value")){
    return set_option("__value", data);
  }else{
    data_string = data;
    int rank = data.size();
    set_option_type(OPTION_TYPE_STRING);
    set_rank_and_shape(1, &rank);
    return 0;
  };
}

/**  Set the data at the supplied option path with the supplied string data.
  */
int FLOption::set_option(std::string str, std::string data){
  if(verbose)
    cout<<"void FLOption::set_option("<<str<<", "<<data<<")\n";

  FLOption* opt = create_child(str);
    
  if(opt == NULL){
    return -1;
  }else{
    return opt->set_option(data);
  }
}

/**  Set the data of this element with the supplied string data, and mark this element as an attribute.
  */
int FLOption::set_attribute(std::string str, std::string data){
  if(verbose)
    cout << "logical_t FLOption::set_attribute(" << str << ", " << data << ")\n";
  
  FLOption* opt = create_child(str);
  
  if(opt == NULL){
    return -1;
  }else{
    int ret = opt->set_option(data);
    opt->set_is_attribute(true);
    return ret;
  }
}

/**  Delete all data from this element.
  */
int FLOption::clear_option(){
  if(verbose)
    cout << "void FLOption::clear_option(void)\n";
    
  set_option_type(OPTION_TYPE_NULL);
  set_rank_and_shape(-1, NULL);
  
  return 0;  
}

/**  Delete all data from the element at the supplied option path.
  */
int FLOption::clear_option(std::string str){
  if(verbose)
    cout << "void FLOption::clear_option(" << str << ")\n";

  FLOption* opt = get_child(str);
  if(opt == NULL){
    return -1;
  }else{
    return opt->clear_option();
  }
}

/**  Delete the element at the supplied option path.
  */
int FLOption::delete_option(std::string str){
  if(verbose)
    cout << "void FLOption::delete_option(" << str << ")\n";

  string branch, name;
  split_name(str, name, branch);
 
  FLOption* opt = get_child(name);
  
  if(opt == NULL){
    return -1;
  }else if(branch.empty()){
    for(multimap<std::string, FLOption>::iterator it = children.begin();it != children.end();it++){
      if(&it->second == opt){
        children.erase(it);
        return 0;
      }
    }
    return -1;
  }else{
    return opt->delete_option(branch);
  }
}

/**  Turn on verbosity for this element (used for debugging only).
  */
void FLOption::verbose_on(){
  verbose = true;
}

/**  Turn off verbosity for this element.
  */
void FLOption::verbose_off(){
  verbose = false;
}

// PRIVATE METHODS

/**  Split the supplied option path in into the highest child name (including its index) and option path from that sub -child.
  */
int FLOption::split_name(const string in, string& name, string& branch) const{
  if(verbose){
    cout << "int FLOption::split_name(" << in << ", " << name << ", " << branch << ")\n";
  }

  // I cannot believe I'm doing this
  string valid_chars("/_:[]1234567890qwertyuioplkjhgfdsazxcvbnmMNBVCXZASDFGHJKLPOIUYTREWQ");
  string fullname = in.substr(0, min(in.size(), in.find_first_not_of(valid_chars)));
 
  // Skip delimiters at beginning.
  string::size_type lastPos = fullname.find_first_not_of("/", 0);
  if(lastPos==string::npos)
    return 0;
  
  // Find next delimiter
  string::size_type pos = fullname.find_first_of("/", lastPos);
  
  if(pos==string::npos){
    name = fullname.substr(lastPos, fullname.size() - lastPos);
  }else{
    name = fullname.substr(lastPos, pos - lastPos);
    branch = fullname.substr(pos, fullname.size()-pos);
  }

  return 0;  
}

/**  Split the supplied option path in into the highest child name (excluding its index), the index of that sub-child, and the option path from that sub-child.
  */
int FLOption::split_name(const string in, string& name, int &index, string& branch) const{
  if(verbose)
    cout<<"int FLOption::split_name("<<in<<", string& name , string& branch)\n";
  
  int ret = split_name(in, name, branch);
  if(ret != 0){
    return ret;
  }    
  
  // Extract the index from the name if necessary
  string::size_type pos = name.find_first_of("[", 0);
  string::size_type lastPos = name.find_first_of("]", 0);
  index = -1;
  if((lastPos-pos)>0){
    istringstream(name.substr(pos+1, lastPos-1))>>index;
    name = name.substr(0, pos);
  }
  
  return 0;
}

/**  Split a node name into the child name (excluding the name attribute) and it's name attribute (which may be empty).
  */
void FLOption::split_node_name(string& node_name, string& name_attr) const{
  if(verbose){
    cout << "void FLOption::split_node_name(" << node_name << ", " << name_attr << "&) const\n";
  }
  
  string::size_type firstPos = this->node_name.rfind("::");
  if(firstPos == string::npos or firstPos == this->node_name.size() - 2){
    node_name = this->node_name;
    name_attr = "";
  }
  else{
    node_name = this->node_name.substr(0, firstPos);
    name_attr = this->node_name.substr(firstPos + 2);
  }
  
  return;
}

/**  Converts the data for this element into a string.
  */
string FLOption::data_as_string() const{
  if(verbose){
    cout << "string FLOption::data_as_string(void) const\n";
  }

  stringstream data_as_string; 
  switch(get_option_type()){
    case(OPTION_TYPE_DOUBLE):
      for(unsigned int i = 0;i < data_double.size();i++){
        data_as_string << data_double[i];
        if(i < data_double.size() - 1){
          data_as_string << " ";
        }
      }
      return data_as_string.str();
    case(OPTION_TYPE_INT):
      for(unsigned int i = 0;i < data_int.size();i++){
        data_as_string << data_int[i];
        if(i < data_int.size() - 1){
          data_as_string << " ";
        }
      }
      return data_as_string.str();
    case(OPTION_TYPE_BOOL):
      for(unsigned int i = 0;i < data_bool.size();i++){
        if(data_bool[i]){
          data_as_string << "true";
        }
        else{
          data_as_string << "false";
        }
        if(i < data_bool.size() - 1){
          data_as_string << " ";
        }
        return data_as_string.str();
      }
      return data_as_string.str();
    case(OPTION_TYPE_NULL):
      return "";
    case(OPTION_TYPE_STRING):
      return data_string;
    default:
      cerr << "ERROR: Invalid option type\n";
      exit(-1);
  }
}

/**  Finds or creates a new child at the supplied option path, and returns that child. If the parent of a created child is marked as an attribute, unmarks it.
  */
FLOption* FLOption::create_child(string str){
  if(verbose)
    cout<<"FLOption& FLOption::create_child("<<str<<")\n";

  if(str == "/" or str.empty())
    return this;
  
  string branch, name;
  int index;
  split_name(str, name, index, branch);

  if(name.empty()){
    cerr << "ERROR: child name cannot be empty\n";
    exit(-1);
  }

  multimap<std::string, FLOption>::iterator child;
  if(children.count(name) == 0){
    string name2 = name + "::";
    int i = 0;
    for(child = children.begin();child != children.end();child++){
      if(child->first.compare(0, name2.size(), name2) == 0){
        if(index < 0 or i == index){
          break;
        }else{
          i++;
        }
      }
    }
    if(child == children.end()){
      if(name == "__value" and get_option_type() != OPTION_TYPE_NULL){
        cerr << "WARNING: Creating __value child for non null element - deleting parent data\n";
        set_option_type(OPTION_TYPE_NULL);
      }
      child = children.insert(pair<string, FLOption>(name, FLOption(node_path + "/" + node_name, name)));
      string new_node_name, name_attr;
      child->second.split_node_name(new_node_name, name_attr);
      if(name_attr.size() > 0){
        child->second.set_attribute("name", name_attr);
      }
      is_attribute = false;
    }
  }else{
    if(index < 0){
      child = children.find(name);
    }else{
      std::pair<std::multimap< std::string, FLOption>::iterator, std::multimap<std::string, FLOption>::iterator> range = children.equal_range(name);
      child = range.first;
      for(int i = 0;child != range.second;child++, i++){
        if(i == index){
          break;
        }
      }
    }
  }

  if(child == children.end()){
    return NULL;
  }else if(branch.empty()){
    return &child->second;
  }else{
    return child->second.create_child(branch);
  }
}

/**  Set the option type for this element, and delete all data of other option types. If the new option type is not string type and this element is marked as an attribute, unmarks it.
  */
void FLOption::set_option_type(FLOptionType option_type){
  switch(option_type){
    case(OPTION_TYPE_DOUBLE):
      data_int.clear();
      data_bool.clear();
      data_string = "";
      is_attribute = false;
      break;
    case(OPTION_TYPE_INT):
      data_double.clear();
      data_bool.clear();
      data_string = "";
      is_attribute = false;
      break;
    case(OPTION_TYPE_BOOL):
      data_double.clear();
      data_int.clear();
      data_string = "";
      is_attribute = false;
      break;
    case(OPTION_TYPE_NULL):
      data_double.clear();
      data_int.clear();
      data_bool.clear();
      data_string = "";
      is_attribute = false;
      break;
    case(OPTION_TYPE_STRING):
      data_double.clear();
      data_int.clear();
      data_bool.clear();
      break;
    default:
      cerr << "ERROR: Invalid option type\n";
      exit(-1);
  }
  
  return;
}

/**  Set the rank and shape for the data in this element.
  */
void FLOption::set_rank_and_shape(int rank, const int* shape){
  logical_t set_attrs = false;
  if(rank > 0){
    FLOptionType option_type = get_option_type();
    set_attrs = (option_type == OPTION_TYPE_DOUBLE or option_type == OPTION_TYPE_INT or option_type == OPTION_TYPE_BOOL);
  }
  switch(rank){
    case(-1):
      this->rank = -1;
      this->shape[0] = -1;
      this->shape[1] = -1;
      break;
    case(0):
      this->rank = 0;
      this->shape[0] = -1;
      this->shape[1] = -1;
      break;
    case(1):
      this->rank = 1;
      this->shape[0] = shape[0];
      this->shape[1] = -1;
      if(set_attrs){
        stringstream rank_as_string;
        rank_as_string << this->rank;
        set_attribute("rank", rank_as_string.str());
        stringstream shape_as_string;
        shape_as_string << shape[0];
        set_attribute("shape", shape_as_string.str());
      }
      break;
    case(2):
      this->rank = 2;
      this->shape[0] = shape[0];
      this->shape[1] = shape[1];
      if(set_attrs){
        stringstream rank_as_string;
        rank_as_string << this->rank;
        set_attribute("rank", rank_as_string.str());
        stringstream shape_as_string;
        shape_as_string << shape[0] << " " << shape[1];
        set_attribute("shape", shape_as_string.str());
      }
      break;
    default:
      cerr << "ERROR: Invalid option rank\n";
      exit(-1);
  }

  return;
}

// END OF FLOption CLASS METHODS

// Initialise the root node
FLOption fluidity_options("", "");


// FORTRAN INTERFACES

extern "C" {
#define chave_option_fc F77_FUNC(chave_option, CHAVE_OPTION)
  int chave_option_fc(const char *str, const int *len){
    if(fluidity_options.have_option(string(str, *len))){
      return 1;
    }else{
      return 0;
    }
  }
  
#define cget_child_name_fc F77_FUNC(cget_child_name, CGET_CHILD_NAME)
  int cget_child_name_fc(const char *str, const int *len, const int *index, char *child_name){
   string name(str, *len);

   if(!fluidity_options.have_option(name))
      return -1;
    
    deque<string> kids;
    fluidity_options.list_children(name, kids);
    
    if(kids.size()<=(size_t)(*index)){
      return -1;
    }

    //strncpy(child_name, kids[*index].c_str(), 8192);
    memcpy(child_name, kids[*index].c_str(), kids[*index].size());
    
    return 0;
  }

#define cget_number_of_children_fc F77_FUNC(cget_number_of_children, CGET_NUMBER_OF_CHILDREN)
  int cget_number_of_children_fc(const char *str, const int *len, int *count){
    *count = 0;
    
    string name(str, *len);

    if(!fluidity_options.have_option(name))
      return -1;

    deque<string> kids;
    fluidity_options.list_children(name, kids);
    
    *count = kids.size();

    return 0;
  }
  
#define cget_option_count_fc F77_FUNC(cget_option_count, CGET_OPTION_COUNT)
  int cget_option_count_fc(const char *str, const int *len, int *count){
    *count = fluidity_options.get_option_count(string(str, *len));
    return 0;
  }

#define cget_option_info_fc F77_FUNC(cget_option_info, CGET_OPTION_INFO)
  int cget_option_info_fc(const char *str, const int *len, int *shape, int *rank, int *type){
    string name(str, *len);

    const FLOption* option = fluidity_options.get_child(name);
    if(option == NULL){
      return -1;
    }

    option->get_option_shape(shape);
    *rank = option->get_option_rank();
    *type = option->get_option_type();
    
    return 0;
  }

#define cget_option_fc F77_FUNC(cget_option, CGET_OPTION)
  int cget_option_fc(const char *str, const int *len, void *val){
    string name(str, *len);
  
    const FLOption* option = fluidity_options.get_child(name);
    
    if(option == NULL){
      return -1;
    }

    if(option->get_option_type()==OPTION_TYPE_BOOL){
      // memcpy(val, option->get_option(), option->get_option_size()*sizeof(double));
      cerr<<"cget_option_fc still broken for logicals\n";
      return -1;
    }else if(option->get_option_type()==OPTION_TYPE_DOUBLE){
      vector<double> data;
      int ret = option->get_option(data);
      if(ret != 0){
        return ret;
      }
      for(size_t i=0;i<data.size();i++)
        ((double *)val)[i] = data[i];
    }else if(option->get_option_type()==OPTION_TYPE_INT){
      vector<int> data;
      int ret = option->get_option(data);
      if(ret != 0){
        return ret;
      }
      for(size_t i=0;i<data.size();i++)
        ((int *)val)[i] = data[i];
    }else if(option->get_option_type()==OPTION_TYPE_STRING){
      string data;
      int ret = option->get_option(data);
      if(ret != 0){
        return ret;
      }
      memcpy(val, data.c_str(), data.size()*sizeof(char));
    }else{
      return -1;
    }
    
    return 0;
  }
  
#define cadd_option_fc F77_FUNC(cadd_option, CADD_OPTION)
  int cadd_option_fc(const char* str, const int* str_len){
    return fluidity_options.add_option(string(str, *str_len));
  }

#define cset_option_fc F77_FUNC(cset_option, CSET_OPTION)
  int cset_option_fc(const char *str, const int *str_len, const int *shape, const int *rank, const int *type, void *data){
    string name(str, *str_len);
    
    // Get the size of the data
    size_t len = 1;
    if((*rank)>0)
      len = *shape;
    for(int i=1;i<(*rank);i++){
      len*=shape[i];
    }

    if(*type == OPTION_TYPE_DOUBLE){
      vector<double> option_data(len);
      for(size_t i=0;i<len;i++)
        option_data[i] = ((double *)data)[i];
      return fluidity_options.set_option(name, *rank, shape, option_data);
    }else if(*type == OPTION_TYPE_INT){
      vector<int> option_data(len);
      for(size_t i=0;i<len;i++)
        option_data[i] = ((int *)data)[i];
      return fluidity_options.set_option(name, *rank, shape, option_data);
    }else if(*type == OPTION_TYPE_STRING){
      return fluidity_options.set_option(name, string((const char *)data, len));
    }else if(*type == OPTION_TYPE_BOOL){
      vector<logical_t> option_data(len);
      for(size_t i=0;i<len;i++)
        option_data[i] = ((logical_t *)data)[i];
      return fluidity_options.set_option(name, *rank, shape, option_data);
    }else{
      cerr << "ERROR: unsupported type passed into set_option(): " << __FILE__ << ", "<< __LINE__ <<endl;
      return -1;
    }
  }
  
#define cset_option_is_attribute_fc F77_FUNC(cset_option_is_attribute, CSET_OPTION_IS_ATTRIBUTE)
  int cset_option_is_attribute_fc(const char *str, const int *str_len, int* is_attribute_set, int* is_attribute_get = NULL){    
    string name(str, *str_len);
    
    FLOption* opt = fluidity_options.get_child(name);
    if(opt == NULL){
      return -1;
    }else{
      logical_t is_attribute = opt->set_is_attribute(*is_attribute_set);
      if(is_attribute_get != NULL){
        *is_attribute_get = is_attribute ? 1 : 0;
      }
      return 0;
    }
  }
  
#define cdelete_option_fc F77_FUNC(cdelete_option, CDELETE_OPTION)
  int cdelete_option_fc(const char* str, const int* len){
    return fluidity_options.delete_option(string(str, *len));
  }
  
#define cload_option_fc F77_FUNC(cload_option, CLOAD_OPTION)
  void cload_option_fc(char* str, const int* len)
  {
    fluidity_options.load_options_xml(string(str, *len));

    return;
  }

#define cwrite_option_fc F77_FUNC(cwrite_option, CWRITE_OPTION)
  void cwrite_option_fc(char* str, const int* len)
  {
    fluidity_options.write_options_xml(string(str, *len));

    return;
  }
}
