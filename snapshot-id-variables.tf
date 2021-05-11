variable "zesty_disk_snapshot_ids" {
  type = map(string)
  default = {
    af-south-1     = "snap-0e2cb5c972c820f07"
    eu-north-1     = "snap-0ff78c28ef9594115"
    ap-south-1     = "snap-0fb2053077c169af7"
    eu-west-3      = "snap-0465d456347efae6c"
    eu-west-2      = "snap-0f19038a86bde248f"
    eu-south-1     = "snap-078edd8014efe790a"
    eu-west-1      = "snap-02ff3ee6bc8a91872"
    ap-northeast-2 = "snap-08d18682aaeaf33be"
    me-south-1     = "snap-087bd48f60e1122ce"
    ap-northeast-1 = "snap-0bbfd407d10372b58"
    sa-east-1      = "snap-033c6ad75f5c89b46"
    ca-central-1   = "snap-02600418e30fb5849"
    ap-east-1      = "snap-01794850217168ace"
    ap-southeast-1 = "snap-05fb9c3e745c46ed9"
    ap-southeast-2 = "snap-0bf3208e700b734a7"
    eu-central-1   = "snap-0c334e7bfb7a8a31a"
    us-east-1      = "snap-0712202f76b8585c4"
    us-east-2      = "snap-099178a8d55156d8c"
    us-west-1      = "snap-019c04f137eb4c2d9"
    us-west-2      = "snap-0fdd4d38f36be4da0"
  }
}
