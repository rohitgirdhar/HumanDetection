function PASannotatedir
  classfilename='PASclasses.txt';
  PASdir='../data/';
  DATdir='Caltech/';
  DATstr='The Caltech database';
  IMGdir='cars/';
  ORGlabel='carsRear';
  PNGdir=[PASdir,DATdir,'PNGImages/',IMGdir];
  ANNdir=[PASdir,DATdir,'Annotations/',IMGdir];
  
  d=dir([PNGdir,'/*.png']);
  for i=1:length(d),
    img=imread([PNGdir,d(i).name]);
    fprintf('-- Now annotating %s --\n',d(i).name);
    record=PASannotateimg(img,classfilename);
    record.imgname=[DATdir,'PNGImages/',IMGdir,d(i).name];
    record.database=DATstr;
    
    for j=1:length(record.objects),
      record.objects(j).orglabel=ORGlabel;
    end;
    
    [path,name,ext]=fileparts(d(i).name);
    annfile=[ANNdir,name,'.txt'];
    comments={}; % Extra comments = array of cells (one per line)
    PASwriterecord(annfile,record,comments);
    if (~PAScmprecords(record,PASreadrecord(annfile)))
      PASerrmsg('Records do not match','');
    end;
  end;
return