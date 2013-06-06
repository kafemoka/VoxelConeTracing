/*
 Copyright (c) 2012 The VCT Project

  This file is part of VoxelConeTracing and is an implementation of
  "Interactive Indirect Illumination Using Voxel Cone Tracing" by Crassin et al

  VoxelConeTracing is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  VoxelConeTracing is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with VoxelConeTracing.  If not, see <http://www.gnu.org/licenses/>.
*/

/*!
* \author Dominik Lazarek (dominik.lazarek@gmail.com)
* \author Andreas Weinmann (andy.weinmann@gmail.com)
*/

#ifndef VCT_SRC_VCT_VCTSCENE_H_
#define VCT_SRC_VCT_VCTSCENE_H_

#include "KoRE/Common.h"

#include "KoRE/TextureBuffer.h"
#include "KoRE/IndexedBuffer.h"
#include "KoRE/Texture.h"
#include "KoRE/SceneNode.h"
#include "KoRE/Components/Camera.h"
#include "KoRE/Components/MeshComponent.h"
#include "NodePool.h"

struct SVCTparameters {
  uint voxel_grid_resolution;
  uint fraglist_size_multiplier;
  glm::vec3 voxel_grid_sidelengths;
};

enum ETex3DContent {
  COLOR_PALETTE,
  BLACK
};

enum EVoxelAttributes {
  VOXELATT_POSITION = 0,
  VOXELATT_COLOR,

  VOXELATT_NUM
};

struct SNode {
  uint next;
  uint color;
};

struct SDrawArraysIndirectCommand {
  SDrawArraysIndirectCommand() :
    numVertices(0),
    numPrimitives(0),
    firstVertexIdx(0),
    baseInstanceIdx(0) {}

  uint numVertices;
  uint numPrimitives;
  uint firstVertexIdx;
  uint baseInstanceIdx;
};

class VCTscene {
public:
  VCTscene();
  ~VCTscene();

  void init(const SVCTparameters& params,
            const std::vector<kore::SceneNode*>& meshNodes,
            kore::Camera* camera);

  inline std::vector<kore::SceneNode*>& getRenderNodes() {return _meshNodes;}
  inline uint getVoxelGridResolution() {return _voxelGridResolution;}

  inline kore::ShaderData* getShdVoxelGridResolution()
                            {return &_shdVoxelGridResolution;}

  inline kore::ShaderData* getShdVoxelFragList(EVoxelAttributes type)
                           {return &_shdVoxelFragLists[type];}



  inline kore::Texture* getVoxelTex()
                          {return &_voxelTex;}
  
  inline kore::TextureBuffer* getVoxelFragList(EVoxelAttributes type) 
    { return &_voxelFragLists[type]; }

  inline kore::TextureBuffer* getFragListIndCmdBuf()
  { return &_fragListIndirectCmdBuf; }

  inline kore::ShaderData* getShdFragListIndCmdBuf()
  {return &_shdFragListIndirectCmdBuf;}

  inline kore::SceneNode* getVoxelGridNode() {return _voxelGridNode;}

  inline kore::Camera* getCamera() {return _camera;}

  inline kore::IndexedBuffer* getAcVoxelIndex() {return &_acVoxelIndex;}
  inline kore::ShaderData* getShdAcVoxelIndex() {return &_shdAcVoxelIndex;}

  inline NodePool* getNodePool() {return &_nodePool;}

 
private:
  kore::Camera* _camera;
  std::vector<kore::SceneNode*> _meshNodes;

  NodePool _nodePool;

  kore::TextureBuffer _voxelFragLists[VOXELATT_NUM];
  kore::STextureInfo _vflTexInfos[VOXELATT_NUM];
  kore::ShaderData _shdVoxelFragLists[VOXELATT_NUM];
  
  uint _voxelGridResolution;
  kore::ShaderData _shdVoxelGridResolution;
  
  glm::vec3 _voxelGridSideLengths;

  kore::IndexedBuffer _acVoxelIndex;
  kore::ShaderData _shdAcVoxelIndex;


  kore::TextureBuffer _fragListIndirectCmdBuf;
  kore::STextureInfo _fragListIcbTexInfos;
  kore::ShaderData _shdFragListIndirectCmdBuf;

  
  

  // Deprecated:
  kore::SceneNode* _voxelGridNode;
  kore::Texture _voxelTex;
  GLuint _tex3DclearPBO;


  uint _fragListSizeMultiplier;
  

  void clearTex3D(kore::Texture* tex);
  void initTex3D(kore::Texture* tex, const ETex3DContent texContent);
  void initVoxelFragList();
  void initIndirectCommandBufs();
  void initNodePool();

  //////////////////////////////////////////////////////////////////////////
};

#endif  // VCT_SRC_VCT_VCTSCENE_H_