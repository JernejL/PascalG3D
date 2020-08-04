unit G3D_model;

// G3DJ (json text) model

{$mode delphi}

interface

uses
	jsontools, TypInfo, sysutils, dglOpenGL, SimpleGameMath, simplegamegenerics;

type

    // specifications: https://github.com/libgdx/fbx-conv/wiki/Version-0.1-%28libgdx-0.9.9%29
	// GUI: https://github.com/ASneakyFox/libgdx-fbxconv-gui/

    // notes:
    // https://github.com/libgdx/libgdx/wiki/Importing-Blender-models-in-LibGDX#rrss-warning

    // http://ogldev.org/www/tutorial38/tutorial38.html
    // https://www.khronos.org/opengl/wiki/Skeletal_Animation

    // https://stackoverflow.com/questions/55989429/understanding-the-skinning-part-of-a-gltf2-0-file-for-opengl-engine

    Matrixtype = Tmatrix4f;
    VectorType = Vector;

	TFloatColor = packed record
		R, G, B, A: single;
	end;

    TBlendWright = packed record
	    BoneID: integer;
	    BoneWeight: single;
    end;

	TGfxMeshVertices = packed record

		TEXCOORD: Vector2; // todo.. could be multiple - not supported yet.
		Color: TFloatColor; // can be also converted from COLORPACKED
		Position: VectorType;
		Normal: VectorType;
		BLENDWEIGHT: array[0..8] of TBlendWright;

        // ignored:
		// TANGENT: VectorType; // curvature
		// BINORMAL: VectorType;

	end;

	{ TGfxMeshSplitIndexes }

    TGfxMeshSplitIndexes = packed record

		MeshIdName: widestring;
		RenderType: integer; // gl_xyz enum - see ConvertToRenderType

		Indexes: array of longword;

        procedure unload();

	end;

	TGfxMesh = packed record
		Vertices: array of TGfxMeshVertices;

        total_uvmaps: integer;
        total_blendweights: integer;

        Splits: array of TGfxMeshSplitIndexes;

        procedure Render();

        procedure unload();
	end;


	{ TGfxMeshMaterial }

	TGfxMeshMaterial = packed record

		MeshIdName: widestring;
		ambient: VectorType;
		diffuse: VectorType;
		emissive: VectorType;
		opacity: single;
		specular: VectorType;
		shininess: single;

        procedure unload();

	end;

	// original skeleton as in file
	TGfxOriginalBones = packed record

		nodeIdName: widestring;
		nodeIndex: integer;
		TransformMatrix: Matrixtype;

	end;

	{ TGfxPart }

	TGfxPart = packed record

		MeshPartIdName: widestring;
		MeshPartIndex: longword;
		MaterialIdName: widestring;
		MaterialIndex: longword;

		Bones: array of TGfxOriginalBones; // TODO: totally forgot about this.

		// uvMapping ?!

        procedure unload;

	end;

	{ TGfxHierarchy }

	TGfxHierarchy = packed record

		BoneIdName: widestring;
		localTransformation: Matrixtype;				// optional in file
        InverseBoneBindTransform: Matrixtype;		// Calculated once (?) - The current transformation (relative to the bind pose) of each bone, may be null. When the part is skinned, this will be * updated by a call to {@link ModelInstance#calculateTransforms()}. Do not set or change this value manually.

        GlobalMatrix: Matrixtype;					// Calculated during rendering pass
        RenderMatrix: Matrixtype;					// global matrix + animation

		MeshParts: array of TGfxPart;

		Hierarchy: array of TGfxHierarchy;

        procedure unload();

	end;

	TGfxKeyframe = packed record

		keytime: single;
		Transformation: Matrixtype;

	end;

	{ TBoneMovement }

	TBoneMovement = packed record

		BoneIdName: widestring;
		BoneIndex: integer;

        max_key_time: single;
		Keyframes: array of TGfxKeyframe;

        function nearest_keyframe(const for_time: single): integer;
        procedure unload;

	end;

	{ TGfxAnimation }

	TGfxAnimation = packed record

		AnimationIdName: widestring;
		TotalLength: single; // todo: cache
        Bones: array of TBoneMovement;

        function FindBone(const bonename: widestring): integer;
        procedure unload();

	end;

	{ TGfxMeshContainer }

	TGfxMeshContainer = record

		MeshData: array of TGfxMesh;
		materials: array of TGfxMeshMaterial;
		Hierarchy: array of TGfxHierarchy;
		Animations: array of TGfxAnimation;

        class operator Initialize(var aRec: TGfxMeshContainer);
        class operator Finalize(var aRec: TGfxMeshContainer);

        procedure LoadFromFile(const filename: widestring);
        procedure Unload();
        procedure Render();

        function FindAnimation(const AnimationName: widestring): integer;
        procedure AnimateBones(const AnimationName: widestring; const for_keyframe: single);

        procedure PrecalculateInverseBoneMatrixes();

        procedure PreCalculateGlobalMatrixes();
        procedure RenderSkeleton();
        procedure RenderMeshByName(const name: widestring);

	end;

	TFormatVertexHelper = record

	    Name: string;
		Values: integer;

	end;

const

	helpers: array[0..25] of TFormatVertexHelper = (
	    (
	    Name : 'POSITION';
	    values : 3;
	    ),
	    (
	    Name : 'NORMAL';
	    values : 3;
	    ),
	    (
	    Name : 'COLOR';
	    values : 4;
	    ),      (
	    Name : 'COLORPACKED';
	    values : 1;
	    ),
	    (
	    Name : 'TANGENT';
	    values : 3;
	    ),
	    (
	    Name : 'BINORMAL';
	    values : 3;
	    ),
	    (
	    Name : 'TEXCOORD';
	    values : 2;
	    ),
	    (
	    Name : 'TEXCOORD0';
	    values : 2;
	    ),
	    (
	    Name : 'TEXCOORD1';
	    values : 2;
	    ),
	    (
	    Name : 'TEXCOORD2';
	    values : 2;
	    ),
	    (
	    Name : 'TEXCOORD3';
	    values : 2;
	    ),
	    (
	    Name : 'TEXCOORD4';
	    values : 2;
	    ),
	    (
	    Name : 'TEXCOORD5';
	    values : 2;
	    ),
	    (
	    Name : 'TEXCOORD6';
	    values : 2;
	    ),
	    (
	    Name : 'TEXCOORD7';
	    values : 2;
	    ),
	    (
	    Name : 'TEXCOORD8';
	    values : 2;
	    ),


	    (
	    Name : 'BLENDWEIGHT';
	    values : 2;
	    ),
	    (
	    Name : 'BLENDWEIGHT0';
	    values : 2;
	    ),
	    (
	    Name : 'BLENDWEIGHT1';
	    values : 2;
	    ),
	    (
	    Name : 'BLENDWEIGHT2';
	    values : 2;
	    ),
	    (
	    Name : 'BLENDWEIGHT3';
	    values : 2;
	    ),
	    (
	    Name : 'BLENDWEIGHT4';
	    values : 2;
	    ),
	    (
	    Name : 'BLENDWEIGHT5';
	    values : 2;
	    ),
	    (
	    Name : 'BLENDWEIGHT6';
	    values : 2;
	    ),
	    (
	    Name : 'BLENDWEIGHT7';
	    values : 2;
	    ),
	    (
	    Name : 'BLENDWEIGHT8';
	    values : 2;
	    )

        // The TEXCOORD and BLENDWEIGHT might be present up to a maximum of 8 times, optionally followed by a suffix which is ignored.

    );

function GetHelperAmoutOfData(const forhelper: string): integer;
function ConvertToRenderType(render_type: string): integer;
procedure ExtractMatrixFromNode(var MatrixOut: Matrixtype; node: TJsonNode);

procedure debug(const message: widestring);

implementation

uses u_rendergdx;


function GetHelperAmoutOfData(const forhelper: string): integer;
var
	i: Integer;
begin

	for i:= 0 to high(helpers) do begin

        if helpers[i].Name = forhelper then
        	exit(helpers[i].Values);

	end;

    exit(-1);

end;

function ConvertToRenderType(render_type: string): integer;
begin

    result:= -1;

    if (render_type = 'TRIANGLES') then
		exit(GL_TRIANGLES);
    if (render_type = 'LINES') then
	    exit(GL_LINES);
	if (render_type = 'POINTS') then
	    exit(GL_POINTS);
	if (render_type = 'TRIANGLE_STRIP') then
	    exit(GL_TRIANGLE_STRIP);
	if (render_type = 'LINE_STRIP') then
	    exit(GL_LINE_STRIP);

end;

procedure ExtractMatrixFromNode(var MatrixOut: Matrixtype; node: TJsonNode);
var
	has_scale, has_translation, has_rotation: TJsonNode;
	q: TQuaternion;

	RotationMatrix,
    ScaleMatrix,
    Translate: Matrixtype;

begin

    RotationMatrix.SetIdentity;
    ScaleMatrix.SetIdentity;
    Translate.SetIdentity;

    has_rotation:= node.Child('rotation');
    has_translation:= node.Child('translation');
    has_scale:= node.Child('scale');

    if assigned(has_rotation) then begin

        q.x:= has_rotation.Child(0).AsNumber;
        q.y:= has_rotation.Child(1).AsNumber;
        q.z:= has_rotation.Child(2).AsNumber;
        q.w:= has_rotation.Child(3).AsNumber;

        RotationMatrix.CreateFromQuaternion(q);

	end;

    if assigned(has_translation) then
        Translate.MakeTranslateMatrix(has_translation.Child(0).AsNumber, has_translation.Child(1).AsNumber, has_translation.Child(2).AsNumber);

    if assigned(has_scale) then
        ScaleMatrix.ScaleGL(has_translation.Child(0).AsNumber, has_translation.Child(1).AsNumber, has_translation.Child(2).AsNumber);

    // TODO: Most probable, the matrix should be built T*R*S order - same is used in gltf and most common.
    MatrixOut:= ScaleMatrix * RotationMatrix * Translate;

end;

procedure debug(const message: widestring);
begin

    u_rendergdx.Form1.log.lines.add(message);

    // todo..

end;

{ TBoneMovement }

function TBoneMovement.nearest_keyframe(const for_time: single): integer;
var
	k: Integer;
    closest: single;
	cct: Single;
begin

    result:= -1;
    closest:= max_key_time;

    // debug(for_time);

    for k:= 0 to high(Keyframes) do begin

        // debug('frame %d key time %0.5f / %0.5f, looking for %0.5f', [ k, Keyframes[k].keytime, max_key_time, for_time ]);

        cct:= Distance1D(Keyframes[k].keytime, for_time);

        if (cct <= closest) then begin

            closest:= cct;
            result:= k;

		end;

	end;

end;

procedure TBoneMovement.unload;
begin

    BoneIdName:= '';

    setlength(Keyframes, 0); // no managed types in there.

end;

{ TGfxPart }

procedure TGfxPart.unload;
begin

    MeshPartIdName:= '';
    MaterialIdName:= '';

    setlength(bones, 0);

end;

{ TGfxHierarchy }

procedure TGfxHierarchy.unload();
var
	i: Integer;
begin

	BoneIdName:= '';

    for i:= 0 to high(MeshParts) do
        MeshParts[i].unload();

    for i:= 0 to high(Hierarchy) do
        Hierarchy[i].unload();

	setlength(MeshParts, 0);
	setlength(Hierarchy, 0);

end;

{ TGfxAnimation }

function TGfxAnimation.FindBone(const bonename: widestring): integer;
var
	b: Integer;
begin

    for b:= 0 to high(bones) do begin

        if (bones[b].BoneIdName = bonename) then exit(b);

	end;

    exit(-1);

end;

procedure TGfxAnimation.unload();
var
	i: Integer;
begin

    AnimationIdName:= '';

    for i:= 0 to high(Bones) do begin

        Bones[i].unload();

	end;

    setlength(Bones, 0);

end;

{ TGfxMeshMaterial }

procedure TGfxMeshMaterial.unload();
begin

    MeshIdName:= '';

end;

{ TGfxMesh }

procedure TGfxMesh.Render();
var
	blw: Integer;
    split, i: integer;
begin

    glDisable(GL_BLEND);

    glPushClientAttrib(GL_CLIENT_VERTEX_ARRAY_BIT);

    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, gl_float, sizeof(vertices[0]), @vertices[0].Position.pointer_to);

    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, gl_float, sizeof(vertices[0]), @vertices[0].TEXCOORD.x);

    glEnableClientState(GL_NORMAL_ARRAY);
    glNormalPointer(gl_float, sizeof(vertices[0]), @vertices[0].Normal.pointer_to);

    glEnableClientState(GL_COLOR_ARRAY);
    glColorPointer(4, gl_float, sizeof(vertices[0]), @vertices[0].Color.R);

    for blw:= 0 to high(vertices[0].BLENDWEIGHT) do begin

        glVertexAttribIPointer((blw * 2), 1, GL_INT, sizeof(vertices[0]), @vertices[0].BLENDWEIGHT[blw].BoneID);
        glVertexAttribPointer((blw * 2) + 1, 1, GL_FLOAT, false, sizeof(vertices[0]), @vertices[0].BLENDWEIGHT[blw].BoneWeight);

    end;

    // todo: TURN OFF OTHER ATTRIB POINTERS.

    for split:= 0 to high(Splits) do begin

        with Splits[split] do begin

        	glDrawElements(RenderType, high(Indexes), GL_UNSIGNED_INT, @Indexes[0]);

            //glbegin(RenderType);
            //
            //debug(GlEnumName(RenderType));
            //
            //for i:= 0 to high(Indexes) do begin
            //
            //    //debug(Vertices[indexes[i]].Position.ToString());
            //    glColor4f( Vertices[indexes[i]].Color.r, Vertices[indexes[i]].color.g, Vertices[indexes[i]].color.B, Vertices[indexes[i]].color.a );
            //
            //    glTexCoord2f( Vertices[indexes[i]].TEXCOORD.x, Vertices[indexes[i]].TEXCOORD.y );
            //
            //    glVertex3f(Vertices[indexes[i]].Position.x, Vertices[indexes[i]].Position.y, Vertices[indexes[i]].Position.z);
            //
			//end;
            //
            //glend;

        end;

    end;

    // todo:
	//BLENDWEIGHT: array[0..8] of VectorType2;

    glPopClientAttrib();

end;

procedure TGfxMesh.unload();
var
	i: Integer;
begin

    for i:= 0 to high(splits) do
    	splits[i].unload();

    SetLength(splits, 0);
    SetLength(Vertices, 0);

end;

{ TGfxMeshSplitIndexes }

procedure TGfxMeshSplitIndexes.unload();
begin

    MeshIdName:= '';
    setlength(Indexes, 0);

end;

{ TGfxMeshContainer }

class operator TGfxMeshContainer.Initialize(var aRec: TGfxMeshContainer);
begin

	with aRec do begin

		SetLength(materials, 0);
		SetLength(Hierarchy, 0);
		SetLength(Hierarchy, 0);

	end;

end;

class operator TGfxMeshContainer.Finalize(var aRec: TGfxMeshContainer);
begin

	with aRec do begin

		SetLength(materials, 0);
		SetLength(Hierarchy, 0);
		SetLength(Hierarchy, 0);

	end;

end;

function parsejsonarrayVectorType(const fromnode: TJsonNode; const withoffset: integer): VectorType;
begin

	result.x:= fromnode.Child(withoffset + 0).AsNumber;
	result.y:= fromnode.Child(withoffset + 1).AsNumber;
	result.z:= fromnode.Child(withoffset + 2).AsNumber;

end;

function parsejsonarrayVector2(const fromnode: TJsonNode; const withoffset: integer): Vector2;
begin

	result.x:= fromnode.Child(withoffset + 0).AsNumber;
	result.y:= fromnode.Child(withoffset + 1).AsNumber;

end;

function ParseBlendWeight(const fromnode: TJsonNode; const withoffset: integer): TBlendWright;
begin

	result.BoneID:=		round(fromnode.Child(withoffset + 0).AsNumber);
	result.BoneWeight:=	fromnode.Child(withoffset + 1).AsNumber;

end;


procedure TGfxMeshContainer.LoadFromFile(const filename: widestring);
var
	//f: Tfile;
    n, attributelist, ModelData, PartData, ArrayIndexes, rootnode_read,
		anim_nodes, BoneArray, curr_bone, keyframes: TJsonNode;

    MeshIndex, m, j, rowsize, vertices_cnt, atofscalc, w, curr_uv, curr_blend, splitpart, splitindex,
		animi, bindex, kf: Integer;
	BufferSpecification: TStringIntHashtable;
	aod: LongInt;
	strkey: widestring;

    procedure ParseNodeHierarchy(var rootnode: TJsonNode; var Hierarchy: array of TGfxHierarchy);
    var
        haschildren, hasparts, has_bones: TJsonNode;
        childi, bone_index, part_parse: integer;
    begin

	    with rootnode do begin

	    	for childi:= 0 to Count - 1 do begin

	            haschildren:= Child(childi).Child('children');
	            hasparts:= Child(childi).Child('parts');

	            Hierarchy[childi].BoneIdName:= Child(childi).Child('id').AsString;

                Hierarchy[childi].RenderMatrix.SetIdentity;
                Hierarchy[childi].InverseBoneBindTransform.SetIdentity;

                ExtractMatrixFromNode( Hierarchy[childi].localTransformation, Child(childi) );

	            if assigned(haschildren) then begin

	                debug(format('%s has %d children.', [ Hierarchy[childi].BoneIdName, haschildren.Count ]));

                    SetLength(Hierarchy[childi].Hierarchy, haschildren.Count);
                    ParseNodeHierarchy(haschildren, Hierarchy[childi].Hierarchy);

	                // setlength(Hierarchy[childi].Hierarchy, haschildren.count);

	                // todo: parse children - TGfxHierarchy

				end;

	            if assigned(hasparts) then begin

	                debug(Hierarchy[childi].BoneIdName + ' has parts: ');

	                setlength(Hierarchy[childi].MeshParts, hasparts.Count);

	                for part_parse:= 0 to high(Hierarchy[childi].MeshParts) do begin

	                    Hierarchy[childi].MeshParts[part_parse].MeshPartIdName:= hasparts.Child(childi).Child('meshpartid').AsString;
	                    Hierarchy[childi].MeshParts[part_parse].MaterialIdName:= hasparts.Child(childi).Child('materialid').AsString;

	                    // todo: caching this as indexes..
	                    //Hierarchy[childi].MeshParts[part_parse].MaterialIndex:=;
	                    //Hierarchy[childi].MeshParts[part_parse].MeshPartIndex:=;

	                    has_bones:= hasparts.Child(childi).Child('bones');

	                    if assigned(has_bones) then begin // has initial pose state data

	                        setlength(Hierarchy[childi].MeshParts[part_parse].Bones, has_bones.Count);

	                        debug(format('%s uses material %s and has %d bones', [ Hierarchy[childi].MeshParts[part_parse].MeshPartIdName, Hierarchy[childi].MeshParts[part_parse].MaterialIdName, has_bones.Count]));

	                        for bone_index := 0 to high(Hierarchy[childi].MeshParts[part_parse].Bones) do begin

	                            Hierarchy[childi].MeshParts[part_parse].Bones[bone_index].nodeIdName:= has_bones.Child(bone_index).Child('node').AsString;
	                            //Hierarchy[childi].MeshParts[part_parse].Bones[bone_index].nodeIndex:=;
                                ExtractMatrixFromNode( Hierarchy[childi].MeshParts[part_parse].Bones[bone_index].TransformMatrix, has_bones.Child(bone_index) );

							end;

						end else begin

	                        debug(format('%s uses material %s and has NO bones', [ Hierarchy[childi].MeshParts[part_parse].MeshPartIdName, Hierarchy[childi].MeshParts[part_parse].MaterialIdName ]));

	                        setlength(Hierarchy[childi].MeshParts[part_parse].Bones, 0);

						end;

					end;

				end;

			end;

		end;

	end;

begin

	//f:= Tfile.create();
    //f.LoadFromFile(filename);

    n:= TJsonNode.Create;

    //alltext:= f.ReadAsText();

    // info( alltext );

    n.LoadFromFile(filename);

    //n.parse( alltext );

    debug(format('%s model file format version: %s.%s', [ filename, n.Child('version').Child(0).ToString, n.Child('version').Child(1).ToString ]));

    // material loader is complete.
    with n.Child('materials') do begin

	    SetLength(materials, count);

        for m:= 0 to high(materials) do begin

        	materials[m].MeshIdName:= Child(m).Child('id').AsString;
            materials[m].ambient:= parsejsonarrayVectorType(Child(m).Child('ambient'), 0);
            materials[m].diffuse:= parsejsonarrayVectorType(Child(m).Child('diffuse'), 0);
            materials[m].emissive:= parsejsonarrayVectorType(Child(m).Child('emissive'), 0);
            materials[m].specular:= parsejsonarrayVectorType(Child(m).Child('specular'), 0);
            materials[m].opacity:= Child(m).Child('opacity').AsNumber;
            materials[m].shininess:= Child(m).Child('shininess').AsNumber;

		end;

	end;

    anim_nodes:= n.Child('animations');

    if assigned(anim_nodes) then
	    with anim_nodes do begin

		    SetLength(Animations, count);

	        for animi:= 0 to high(Animations) do begin

	        	Animations[animi].AnimationIdName:= Child(animi).Child('id').AsString;

                Animations[animi].TotalLength:= 0;

                setlength(Animations[animi].Bones, 0);

                BoneArray:= Child(animi).Child('bones');

                setlength(Animations[animi].Bones, BoneArray.count);

                for bindex:= 0 to high(Animations[animi].Bones) do begin

                    curr_bone:= BoneArray.Child(bindex);

                    Animations[animi].Bones[bindex].BoneIdName:= curr_bone.Child('boneId').AsString;

                    Animations[animi].Bones[bindex].max_key_time:= 0;

                    keyframes:= curr_bone.Child('keyframes');
                    setlength(Animations[animi].Bones[bindex].Keyframes, keyframes.count);

                    for kf:= 0 to high(Animations[animi].Bones[bindex].Keyframes) do begin

                        with keyframes.Child(kf) do begin

                            Animations[animi].Bones[bindex].Keyframes[kf].keytime:= Child('keytime').AsNumber;

                            if (Animations[animi].Bones[bindex].Keyframes[kf].keytime > Animations[animi].Bones[bindex].max_key_time) then
                            	Animations[animi].Bones[bindex].max_key_time:= Animations[animi].Bones[bindex].Keyframes[kf].keytime;

                            ExtractMatrixFromNode( Animations[animi].Bones[bindex].Keyframes[kf].Transformation, keyframes.Child(kf) );

						end;

					end;

                    if (Animations[animi].Bones[bindex].max_key_time > Animations[animi].TotalLength) then
                    	Animations[animi].TotalLength:= Animations[animi].Bones[bindex].max_key_time;

				end;

			end;

		end;

    with n.Child('meshes') do begin

	    SetLength(MeshData, count);

        for MeshIndex:= 0 to high(MeshData) do begin

            attributelist:= Child(MeshIndex).Child('attributes').AsArray;

            BufferSpecification:= TStringIntHashtable.create(attributelist.Count);

            atofscalc:= 0;
            rowsize:= 0;

            for j:= 0 to attributelist.Count - 1 do begin // todo: can optimize, keep value in var

                aod:= GetHelperAmoutOfData(attributelist.Child(j).AsString);

                if (aod < 1) then debug('Cannot find data size for ' + attributelist.Child(j).AsString);

                rowsize += aod;

            	BufferSpecification.Push(attributelist.Child(j).AsString, atofscalc);
                atofscalc += aod;

			end;

            ModelData:= Child(MeshIndex).Child('vertices').AsArray;
            vertices_cnt:= (ModelData.count) div rowsize;
            debug(format('row size is %d values = %d vertices.', [ rowsize, vertices_cnt]));

            setlength(MeshData[MeshIndex].Vertices, vertices_cnt);

            for j:= 0 to vertices_cnt - 1 do begin // for each row

                initialize(MeshData[MeshIndex].Vertices[j].BLENDWEIGHT);

                curr_uv:= 0;
                curr_blend:= 0;

                for w := 0 to BufferSpecification.highest do begin

                    strkey:= BufferSpecification.hashkey[w];

                    if strkey = 'POSITION'				then MeshData[MeshIndex].Vertices[j].Position:= parsejsonarrayVectorType(ModelData, (j * rowsize) + BufferSpecification.values[w]);
                    if strkey = 'NORMAL'				then MeshData[MeshIndex].Vertices[j].Normal:= parsejsonarrayVectorType(ModelData, (j * rowsize) + BufferSpecification.values[w]);
                    if (Pos('TEXCOORD', strkey) <> -1)	then begin
                    	MeshData[MeshIndex].Vertices[j].TEXCOORD:= parsejsonarrayVector2(ModelData, (j * rowsize) + BufferSpecification.values[w]);
                        curr_uv += 1;
					end;

                    // MeshData[MeshIndex].total_uvmaps += 1;

                    if (Pos('BLENDWEIGHT', strkey) <> -1)	then begin
                    	MeshData[MeshIndex].Vertices[j].BLENDWEIGHT[curr_blend]:= ParseBlendWeight(ModelData, (j * rowsize) + BufferSpecification.values[w]);
                        curr_blend += 1;
					end;

			        //debug(format('Read row %d attribute %s at index %d', [ j, BufferSpecification.hashkey[w], BufferSpecification.values[w] ]));

                    // ModelData[j * rowsize] + BufferSpecification.values[w];

				end;

                MeshData[MeshIndex].total_uvmaps:= curr_uv;
                MeshData[MeshIndex].total_blendweights:= curr_blend; // toto: maybe keep this on main model instace as well.

			end;

            freeandnil(BufferSpecification);

            PartData:= Child(MeshIndex).Child('parts').AsArray;

            setlength(MeshData[MeshIndex].Splits, PartData.Count);

            for splitpart:= 0 to high(MeshData[MeshIndex].Splits) do begin

                MeshData[MeshIndex].Splits[splitpart].MeshIdName:= PartData.Child(splitpart).Child('id').AsString;
                MeshData[MeshIndex].Splits[splitpart].RenderType:= ConvertToRenderType(PartData.Child(splitpart).Child('type').AsString);

                ArrayIndexes:= PartData.Child(splitpart).Child('indices').AsArray;

                setlength(MeshData[MeshIndex].Splits[splitpart].Indexes, ArrayIndexes.Count);

                for splitindex:= 0 to high(MeshData[MeshIndex].Splits[splitpart].Indexes) do begin
                	MeshData[MeshIndex].Splits[splitpart].Indexes[splitindex] := round(ArrayIndexes.Child(splitindex).AsNumber);
                end;

                debug(format('New split mesh: %s - %d vertices.', [ MeshData[MeshIndex].Splits[splitpart].MeshIdName, length(MeshData[MeshIndex].Splits[splitpart].Indexes) ]));

                //ArrayIndexes.Child(withoffset + 0).AsNumber
				;

			end;

		end;

	end;

    SetLength(Hierarchy, 0);

    rootnode_read:= n.Child('nodes');

    SetLength(Hierarchy, rootnode_read.Count);
    ParseNodeHierarchy(rootnode_read, Hierarchy);

    PreCalculateGlobalMatrixes();
    PrecalculateInverseBoneMatrixes();

    FreeAndNil(n);
    //freeandnil(f);

end;

procedure TGfxMeshContainer.Unload();
var
	i: Integer;
begin

	for i:= 0 to high(MeshData) do
        MeshData[i].unload();

    setlength(MeshData, 0);

	for i:= 0 to high(materials) do
        materials[i].unload();

    setlength(materials, 0);

    for i:= 0 to high(Animations) do
        Animations[i].unload();

    setlength(Animations, 0);

	for i:= 0 to high(Hierarchy) do
        Hierarchy[i].unload();

    setlength(Hierarchy, 0);

end;

// Todo: implement
procedure TGfxMeshContainer.Render();
var
	i: Integer;

    procedure RenderResurseModel(HierarchyChildren: array of TGfxHierarchy);
	var
		j, parts: Integer;
    begin

    	for j:= 0 to high(HierarchyChildren) do begin

            glPushMatrix();

            glMultMatrixf(@HierarchyChildren[j].localTransformation);
            //glMultMatrixf(@HierarchyChildren[j].RenderMatrix);

            for parts:= 0 to high(HierarchyChildren[j].MeshParts) do begin

                // debug('mesh part %s', [ HierarchyChildren[j].MeshParts[parts].MeshPartIdName ]);

            	RenderMeshByName(HierarchyChildren[j].MeshParts[parts].MeshPartIdName);

			end;

            RenderResurseModel(HierarchyChildren[j].Hierarchy); // render the rest.

            glPopMatrix();

		end;

	end;

begin

    // procedure should be, to build render hierarchy order (first solid, then transparent parts)
    // after this, all matrix hierarchies are calculated depending on hierarchy and bone skeleton
    // then a keyframe is picked and set.

    RenderResurseModel(Hierarchy);

end;

function TGfxMeshContainer.FindAnimation(const AnimationName: widestring): integer;
var
	a: Integer;
begin

	for a:= 0 to high(Animations) do begin

        if (Animations[a].AnimationIdName = AnimationName) then
            exit(a);

	end;

    exit(-1);

end;

(** Calculates the local and world transform of all {@link Node} instances in this model, recursively. First each
 * {@link Node#localTransform} transform is calculated based on the translation, rotation and scale of each Node. Then each
 * {@link Node#calculateWorldTransform()} is calculated, based on the parent's world transform and the local transform of each
 * Node. Finally, the animation bone matrices are updated accordingly.</p>
 *
 * This method can be used to recalculate all transforms if any of the Node's local properties (translation, rotation, scale)
 * was modified. *)

procedure TGfxMeshContainer.AnimateBones(const AnimationName: widestring; const for_keyframe: single);
var
	AnimationIndex: Integer;

    procedure HierarhicallySetBoneAnimMatrix(var HierarchyChildren: array of TGfxHierarchy; Parentmatrix: Matrixtype);
	var
		j, findbone, keyframe: Integer;
		Tempmatrix, PosedMatrix, TempMatrixBone, copymatrix: Matrixtype;
    begin

    	for j:= 0 to high(HierarchyChildren) do begin

            // HierarchyChildren[j].RenderMatrix:= HierarchyChildren[j].GlobalMatrix;

            HierarchyChildren[j].RenderMatrix:= HierarchyChildren[j].localTransformation * Parentmatrix;

            findbone:= Animations[AnimationIndex].FindBone(HierarchyChildren[j].BoneIdName);

            if findbone <> -1 then begin

                keyframe:= 0; // Animations[AnimationIndex].Bones[findbone].nearest_keyframe(for_keyframe);

                if keyframe <> -1 then begin

                    PosedMatrix:= Animations[AnimationIndex].Bones[findbone].Keyframes[keyframe].Transformation;

                    // https://github.com/libgdx/libgdx/blob/a4805d6a017b80622d6bfdd3a791352257a3c539/gdx/src/com/badlogic/gdx/graphics/g3d/model/Node.java#L88
                    // part.bones[i].set(part.invBoneBindTransforms.keys[i].globalTransform).mul(part.invBoneBindTransforms.values[i]);

                    // HierarchyChildren[j].RenderMatrix:= IdentityVal;// HierarchyChildren[j].InverseBoneBindTransform * Animations[AnimationIndex].Bones[findbone].Keyframes[keyframe].Transformation;
                    // HierarchyChildren[j].RenderMatrix:= HierarchyChildren[j].InverseBoneBindTransform * Animations[AnimationIndex].Bones[findbone].Keyframes[keyframe].Transformation;
                    // HierarchyChildren[j].RenderMatrix:= HierarchyChildren[j].InverseBoneBindTransform * Animations[AnimationIndex].Bones[findbone].Keyframes[keyframe].Transformation;
                    // HierarchyChildren[j].GlobalMatrix *

                    // HierarchyChildren[j].localTransformation:= Animations[AnimationIndex].Bones[findbone].Keyframes[keyframe].Transformation;

                    //debug('Bone: ' + HierarchyChildren[j].BoneIdName);
                    //debug('Local node Transform' + HierarchyChildren[j].localTransformation.tostring());
                    //debug('Inverse: ' + HierarchyChildren[j].InverseBoneBindTransform.tostring());
                    //debug(format('Animation matrix: for keyframe %d =', [ keyframe ]) + Animations[AnimationIndex].Bones[findbone].Keyframes[keyframe].Transformation.tostring());

                 //   debug('Bone: ' + HierarchyChildren[j].BoneIdName);
                 //   debug('Parent Node Transform: ' + #13 + Parentmatrix.tostring());
                 //   debug('Local Skeleton Node Transform: ' + #13 + HierarchyChildren[j].localTransformation.tostring());
                 //   debug('Animation Node Transform: ' + #13 + PosedMatrix.tostring());
                 //   debug('Local * Anim = ' + #13 + (PosedMatrix * HierarchyChildren[j].localTransformation).tostring());
                 //
                    // debug('Global matrix Without animation: ' + #13 + HierarchyChildren[j].GlobalMatrix.tostring());

                    //debug(format('Animation matrix: for keyframe %d =', [ keyframe ]) + Animations[AnimationIndex].Bones[findbone].Keyframes[keyframe].Transformation.tostring());

                    //PosedMatrix.MatrixInverse();
                    //PosedMatrix:= PosedMatrix.Transpose();

                    copymatrix:= IdentityVal;

                    //copymatrix:= HierarchyChildren[j].localTransformation;
                    //copymatrix.MatrixInverse();

                    TempMatrixBone:= (PosedMatrix * copymatrix) * HierarchyChildren[j].localTransformation;

                    HierarchyChildren[j].RenderMatrix:= (PosedMatrix) * Parentmatrix;

                    // debug('Global matrix = ' + #13 + (HierarchyChildren[j].RenderMatrix).tostring());

                    // DebugBreak;

                    //HierarchyChildren[j].RenderMatrix:= PosedMatrix * HierarchyChildren[j].localTransformation * Parentmatrix;



                    // HierarchyChildren[j].RenderMatrix:= HierarchyChildren[j].InverseBoneBindTransform * Animations[AnimationIndex].Bones[findbone].Keyframes[keyframe].Transformation ;

                    //Tempmatrix:= HierarchyChildren[j].localTransformation * HierarchyChildren[j].InverseBoneBindTransform;

                    // HierarchyChildren[j].RenderMatrix:= Parentmatrix * Tempmatrix; // * Animations[AnimationIndex].Bones[findbone].Keyframes[keyframe].Transformation

                    // globalTransform.set(parent.globalTransform).mul(localTransform);

                    //HierarchyChildren[j].GlobalMatrix:= HierarchyChildren[j].localTransformation * Parentmatrix;

                	// HierarchyChildren[j].RenderMatrix *

				end;

			end;

            HierarhicallySetBoneAnimMatrix(HierarchyChildren[j].Hierarchy, HierarchyChildren[j].RenderMatrix ); // render the rest.

		end;

	end;

begin

	AnimationIndex:= 0; // hack - todo.. FindAnimation(AnimationName)

    HierarhicallySetBoneAnimMatrix(Hierarchy, IdentityVal);

end;

procedure TGfxMeshContainer.PrecalculateInverseBoneMatrixes();

    procedure HierarhicallyCalculateInverseBindPose(var HierarchyChildren: array of TGfxHierarchy; Parentmatrix: Matrixtype);
	var
		j, parts, mp, meshbone: Integer;
		Vecpos: VectorType;
    begin

        // GlobalMatrix



    	for j:= 0 to high(HierarchyChildren) do begin

            // m_BoneInfo[BoneIndex].FinalTransformation = m_GlobalInverseTransform * GlobalTransformation * m_BoneInfo[BoneIndex].BoneOffset;

            //HierarchyChildren[j].GlobalMatrix:= HierarchyChildren[j].localTransformation * Parentmatrix;



            // HierarchyChildren[j].BoneIdName

            for mp:= 0 to high(HierarchyChildren[j].MeshParts) do begin

                for meshbone:= 0 to high(HierarchyChildren[j].MeshParts[mp].Bones) do begin

                    // HierarchyChildren[j].MeshParts[mp].Bones[meshbone].nodeIdName
                    // TransformMatrix

				end;

			end;

            HierarchyChildren[j].InverseBoneBindTransform:= HierarchyChildren[j].localTransformation; // GlobalMatrix
            HierarchyChildren[j].InverseBoneBindTransform.MatrixInverseV2();

            HierarhicallyCalculateInverseBindPose(HierarchyChildren[j].Hierarchy, HierarchyChildren[j].GlobalMatrix); // render the rest.

		end;

	end;

begin

    // The "inverse bind pose" basically "undoes" any transformation that has already been applied to your model in its bind pose.

    // mOffsetMatrix (inverse bind matrix caculated by Assimp)
    // https://github.com/assimp/assimp/pull/1803
    // transform from bone space to mesh space.

    HierarhicallyCalculateInverseBindPose(Hierarchy, identityVal);

end;

procedure TGfxMeshContainer.PreCalculateGlobalMatrixes();

    procedure HierarhicallyCalculateGlobalMatrix(var HierarchyChildren: array of TGfxHierarchy; Parentmatrix: Matrixtype);
	var
		j, parts: Integer;
		Vecpos: VectorType;
    begin

    	for j:= 0 to high(HierarchyChildren) do begin

            // m_BoneInfo[BoneIndex].FinalTransformation = m_GlobalInverseTransform * GlobalTransformation * m_BoneInfo[BoneIndex].BoneOffset;

            HierarchyChildren[j].GlobalMatrix:= HierarchyChildren[j].localTransformation * Parentmatrix;

            HierarhicallyCalculateGlobalMatrix(HierarchyChildren[j].Hierarchy, HierarchyChildren[j].GlobalMatrix); // render the rest.

		end;

	end;

begin

    // The "inverse bind pose" basically "undoes" any transformation that has already been applied to your model in its bind pose.

    // mOffsetMatrix (inverse bind matrix caculated by Assimp)
    // https://github.com/assimp/assimp/pull/1803
    // transform from bone space to mesh space.



    HierarhicallyCalculateGlobalMatrix(Hierarchy, identityVal);

end;

procedure TGfxMeshContainer.RenderSkeleton();
var
    StartMatrix: Matrixtype;
	timeindex: Single;

    procedure RenderResurseModelBones(const level: integer; var HierarchyChildren: array of TGfxHierarchy; ModelviewMatrix: Matrixtype; ParentBoneGMatrix: Matrixtype);
	var
		j, parts: Integer;
		Vecpos: VectorType;
		Currmatrix: Matrixtype;
    begin

    	for j:= 0 to high(HierarchyChildren) do begin

            if ( (level = 0) and (length(HierarchyChildren[j].Hierarchy) = 0) ) then continue; // on level 0 only render things which have child nodes.

            glBegin(GL_lines);

	        	glColor4f(1, 0, 0, 1);
                Vecpos:= ParentBoneGMatrix.TransformVector(nullVector);
                glVertex3f(vecpos.x, vecpos.y, vecpos.z);

                Vecpos:= HierarchyChildren[j].RenderMatrix.TransformVector(nullVector);
                glColor4f(0, 0, 1, 1);
	            glVertex3f(vecpos.x, vecpos.y, vecpos.z);

        	glend;

            glBegin(gl_points);

            	glVertex3f(vecpos.x, vecpos.y, vecpos.z);

            glend;

            //vecpos:= (HierarchyChildren[j].RenderMatrix * ModelviewMatrix).TransformVector(nullVectorType);
            //Mirageshapes.AddText(vecpos, HierarchyChildren[j].BoneIdName, mirageshapes.default_mirage_time);

            RenderResurseModelBones(level + 1, HierarchyChildren[j].Hierarchy, ModelviewMatrix, HierarchyChildren[j].RenderMatrix); // render the rest.

		end;

	end;

begin

    //timeindex:= Frand(Animations[0].TotalLength, Animations[0].TotalLength / length(Animations[0].Bones));

    timeindex:= 0.0; // InterpolateRanges(sin(engine.Time_Linear * 0.01), 0.0, 1.0, 0.0, Animations[0].TotalLength);

    //debug('want %0.5f total %0.5f', [ timeindex, Animations[0].TotalLength]);

    AnimateBones('asdasdsa', timeindex);
    //PreCalculateGlobalMatrixes();

    glPushAttrib(GL_ALL_ATTRIB_BITS);

    glColor4f(1, 0, 0, 1);

    glLineWidth(2);
    glPointSize(10);

    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);

    glDisable(gl_depth_test);

    StartMatrix:= identityVal;

    glGetFloatv(GL_MODELVIEW_MATRIX, @StartMatrix.pointer_to);

    glPushMatrix();

    	//glLoadIdentity();
    	RenderResurseModelBones(0, Hierarchy, startmatrix, identityVal);

    glPopMatrix();

    glPopAttrib();

end;

procedure TGfxMeshContainer.RenderMeshByName(const name: widestring);
var
    i: integer;
    s: integer;
begin

	for i:= 0 to high(MeshData) do begin

        for s:= 0 to high(MeshData[i].splits) do begin

            if (MeshData[i].splits[i].MeshIdName = name) then begin
        		MeshData[i].Render();
                exit; // TODO: can they repeat?
			end;

        end;

	end;

    debug(format('Node %s not found.', [ name ]));

end;

end.

